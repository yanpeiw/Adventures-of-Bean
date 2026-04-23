extends CharacterBody2D

@onready var sprite : Sprite2D = $Sprite2D

var char_id : String = "wizard"

const ATTACK_FPS  : float = 12.0
const CAST_FPS    : float = 8.0

const JOYSTICK_CENTER : Vector2 = Vector2(80.0, 400.0)
const JOYSTICK_RADIUS : float   = 50.0

var lpc_char          : Node2D = null
var facing            : String = ""
var cast_looping      : bool   = false
var active_kamehameha : Node2D = null

var touch_id     : int     = -1
var joystick_dir : Vector2 = Vector2.ZERO

@onready var joystick_base : Control = $"../UILayer/JoystickBase"
@onready var joystick_knob : Control = $"../UILayer/JoystickKnob"

var sword_cooldown    : float = 0.0
var ability_cooldown  : float = 0.0
var ult_cooldown      : float = 0.0
var contact_hit_timer : float = 0.0
var prev_hearts       : int   = -1

var ult_aiming    : bool    = false
var ult_aim_dir   : Vector2 = Vector2.RIGHT
var aim_indicator : Node2D  = null

# ── Ready ──────────────────────────────────────────────────────────────────────
func _ready() -> void:
	add_to_group("player")
	z_index = 3
	sprite.hide()
	var selected : String = GameState.selected_character
	char_id = selected if ResourceLoader.exists("res://art/lpc/body_light.png") else "wizard"
	_build_lpc_char()
	_set_facing("east")
	_build_joystick_visuals()

const CHIBI_CHARS : Array = ["healer", "warrior", "wizard"]

func _build_lpc_char() -> void:
	if lpc_char and is_instance_valid(lpc_char):
		lpc_char.queue_free()
	var script_path : String = (
		"res://scripts/player/ChibiCharacter.gd"
		if char_id in CHIBI_CHARS else
		"res://scripts/player/LPCCharacter.gd"
	)
	lpc_char = load(script_path).new()
	lpc_char.z_index = 0
	add_child(lpc_char)
	lpc_char.setup(char_id)
	_build_shadow()

func _build_shadow() -> void:
	var shadow : Node2D = load("res://scripts/effects/ShadowBlob.gd").new()
	shadow.position = Vector2(4.0, 17.0)
	shadow.set("blob_w", 30.0)
	shadow.set("blob_h", 10.0)
	add_child(shadow)
	move_child(shadow, 0)

func _set_facing(dir : String) -> void:
	if dir == facing:
		return
	facing = dir
	if lpc_char:
		lpc_char.set_facing(dir)

func _build_joystick_visuals() -> void:
	var base_style := StyleBoxFlat.new()
	base_style.bg_color                   = Color(1, 1, 1, 0.12)
	base_style.corner_radius_top_left     = 60
	base_style.corner_radius_top_right    = 60
	base_style.corner_radius_bottom_left  = 60
	base_style.corner_radius_bottom_right = 60
	var base_p := Panel.new()
	base_p.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base_p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base_p.add_theme_stylebox_override("panel", base_style)
	joystick_base.add_child(base_p)

	var knob_style := StyleBoxFlat.new()
	knob_style.bg_color                   = Color(1, 1, 1, 0.45)
	knob_style.corner_radius_top_left     = 30
	knob_style.corner_radius_top_right    = 30
	knob_style.corner_radius_bottom_left  = 30
	knob_style.corner_radius_bottom_right = 30
	var knob_p := Panel.new()
	knob_p.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	knob_p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	knob_p.add_theme_stylebox_override("panel", knob_style)
	joystick_knob.add_child(knob_p)
	_reset_knob()

func _reset_knob() -> void:
	joystick_knob.position = JOYSTICK_CENTER - Vector2(30.0, 30.0)

# ── Sword slash ────────────────────────────────────────────────────────────────
func sword_slash() -> void:
	if sword_cooldown > 0.0:
		return
	if lpc_char and lpc_char.is_busy():
		return
	sword_cooldown = 1.0 / (1.5 * (1.0 + GameState.attack_speed_bonus))
	var dmg : int = GameState.get_attack_damage() + GameState.get_weapon_damage()
	var fwd : Vector2 = _dir_to_nearest_enemy()
	_set_facing("east" if fwd.x >= 0.0 else "west")
	_fire_crescent(fwd, dmg)
	if lpc_char:
		lpc_char.play_anim("attack", ATTACK_FPS)

func _fire_crescent(fwd : Vector2, dmg : int) -> void:
	var c : Node2D = load("res://scripts/effects/SwordSmear.gd").new()
	c.direction = fwd
	c.damage    = dmg
	c.max_range = max(GameState.get_weapon_range() * 2.2, 280.0)
	get_parent().add_child(c)
	c.global_position = global_position + fwd * 18.0

# ── Class ability ──────────────────────────────────────────────────────────────
func class_ability() -> void:
	if ability_cooldown > 0.0:
		return
	var ab : Dictionary = GameState.get_spell_stats()
	if not GameState.spend_energy(ab.get("energy_cost", 999.0)):
		return
	ability_cooldown = ab.get("cooldown", 5.0)

	match GameState.selected_character:
		"wizard":
			_fire_fireball(ab, Color(1.0, 0.50, 0.04))
		"warrior":
			_fire_fireball(ab, Color(1.0, 0.15, 0.05))
			_do_aoe_damage(ab.get("base_damage", 3), ab.get("radius", 120.0), Color(1.0, 0.3, 0.1))
		"healer":
			_fire_fireball(ab, Color(0.2, 1.0, 0.45))
			_do_aoe_damage(ab.get("base_damage", 2), ab.get("radius", 150.0), Color(0.3, 1.0, 0.5))

	if lpc_char:
		lpc_char.play_anim("cast", CAST_FPS)

# ── Ultimate ───────────────────────────────────────────────────────────────────
func ult_button_down() -> void:
	if ult_cooldown > 0.0:
		return
	if char_id == "wizard":
		_fire_wizard_ult_held()
	else:
		_start_ult_aim()

func ult_button_up() -> void:
	if char_id == "wizard":
		if active_kamehameha and is_instance_valid(active_kamehameha):
			active_kamehameha.set("held", false)
			active_kamehameha = null
		_stop_cast_loop()
	elif ult_aiming:
		ult_aiming = false
		_hide_aim_indicator()
		use_ultimate()

func _fire_wizard_ult_held() -> void:
	var ult : Dictionary = GameState.get_ultimate_stats()
	if not GameState.spend_energy(ult.get("energy_cost", 999.0)):
		return
	ult_cooldown      = ult.get("cooldown", 12.0)
	active_kamehameha = _fire_kamehameha(ult, Color(1.0, 0.55, 0.05))
	_start_cast_loop()

func use_ultimate() -> void:
	if ult_cooldown > 0.0:
		return
	var ult : Dictionary = GameState.get_ultimate_stats()
	if not GameState.spend_energy(ult.get("energy_cost", 999.0)):
		return
	ult_cooldown = ult.get("cooldown", 12.0)

	match GameState.selected_character:
		"warrior":
			_fire_kamehameha(ult, Color(1.0, 0.15, 0.08))
			_do_aoe_damage(ult.get("base_damage", 6), ult.get("radius", 160.0), Color(1.0, 0.15, 0.1))
		"healer":
			GameState.heal(ult.get("heal", 2))
			_fire_kamehameha(ult, Color(0.2, 1.0, 0.5))
			_do_aoe_damage(ult.get("base_damage", 3), ult.get("radius", 140.0), Color(0.2, 1.0, 0.6))

	if lpc_char:
		lpc_char.play_anim("cast", CAST_FPS)

func _do_aoe_damage(dmg : int, radius : float, ring_color : Color = Color(0.9, 0.6, 1.0)) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if global_position.distance_to(enemy.global_position) < radius:
			enemy.take_damage(dmg)
	var ring : Node2D = load("res://scripts/effects/AoeRing.gd").new()
	ring.radius = radius
	ring.color  = ring_color
	get_parent().add_child(ring)
	ring.global_position = global_position

func _dir_to_nearest_enemy() -> Vector2:
	var best_dist : float   = INF
	var best_dir  : Vector2 = _facing_vec()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var d : float = global_position.distance_to(enemy.global_position)
		if d < best_dist:
			best_dist = d
			best_dir  = (enemy.global_position - global_position).normalized()
	return best_dir

func _fire_fireball(ab : Dictionary, color : Color = Color(1.0, 0.50, 0.04)) -> void:
	var fb : Node2D = load("res://scripts/effects/Fireball.gd").new()
	fb.direction  = _dir_to_nearest_enemy()
	fb.damage     = ab.get("base_damage", 3)
	fb.speed      = ab.get("projectile_speed", 270.0)
	fb.max_range  = ab.get("range", 400.0)
	fb.set("proj_color", color)
	get_parent().add_child(fb)
	fb.global_position = global_position

func _fire_kamehameha(ult : Dictionary, color : Color = Color(1.0, 0.55, 0.05)) -> Node2D:
	var kh : Node2D = load("res://scripts/effects/Kamehameha.gd").new()
	kh.direction  = _dir_to_nearest_enemy()
	kh.damage     = ult.get("base_damage", 10)
	kh.beam_width = ult.get("beam_width", 34.0)
	kh.max_length = ult.get("range", 720.0)
	kh.set("beam_color",  color)
	kh.set("follow_node", self)
	get_parent().add_child(kh)
	kh.global_position = global_position
	return kh

# ── Aim indicator ──────────────────────────────────────────────────────────────
func _start_ult_aim() -> void:
	ult_aiming  = true
	ult_aim_dir = _facing_vec()
	_show_aim_indicator()

func _show_aim_indicator() -> void:
	if aim_indicator:
		return
	aim_indicator = Node2D.new()
	var glow := ColorRect.new()
	glow.color    = Color(1.0, 0.38, 0.0, 0.22)
	glow.size     = Vector2(220.0, 22.0)
	glow.position = Vector2(10.0, -11.0)
	aim_indicator.add_child(glow)
	var line := ColorRect.new()
	line.color    = Color(1.0, 0.65, 0.1, 0.85)
	line.size     = Vector2(200.0, 6.0)
	line.position = Vector2(10.0, -3.0)
	aim_indicator.add_child(line)
	add_child(aim_indicator)

func _hide_aim_indicator() -> void:
	if aim_indicator:
		aim_indicator.queue_free()
		aim_indicator = null

# ── Cast loop (kamehameha hold) ────────────────────────────────────────────────
func _start_cast_loop() -> void:
	cast_looping = true
	if lpc_char:
		lpc_char.start_cast_loop(CAST_FPS)

func _stop_cast_loop() -> void:
	cast_looping = false
	if lpc_char:
		lpc_char.stop_cast_loop()

# ── Hit flash ──────────────────────────────────────────────────────────────────
func _on_hit(amount : int) -> void:
	if lpc_char:
		var t := lpc_char.create_tween()
		t.tween_property(lpc_char, "modulate", Color(2.5, 0.15, 0.15, 1.0), 0.05)
		t.tween_property(lpc_char, "modulate", Color(1.8, 0.3,  0.3,  1.0), 0.10)
		t.tween_property(lpc_char, "modulate", Color.WHITE,                  0.25)
	var dn : Node2D = load("res://scripts/effects/DamageNumber.gd").new()
	get_parent().add_child(dn)
	dn.global_position = global_position + Vector2(randf_range(-8.0, 8.0), -32.0)
	dn.setup(amount)

func _facing_vec() -> Vector2:
	return Vector2.RIGHT if facing == "east" else Vector2.LEFT

# ── Input ──────────────────────────────────────────────────────────────────────
func _input(event : InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_id == -1 and event.position.x < 427.0:
			touch_id     = event.index
			joystick_dir = Vector2.ZERO
			_reset_knob()
		elif not event.pressed and event.index == touch_id:
			touch_id     = -1
			joystick_dir = Vector2.ZERO
			velocity     = Vector2.ZERO
			_reset_knob()
	if event is InputEventScreenDrag and event.index == touch_id:
		var delta : Vector2 = event.position - JOYSTICK_CENTER
		if delta.length() > JOYSTICK_RADIUS:
			delta = delta.normalized() * JOYSTICK_RADIUS
		joystick_dir           = delta / JOYSTICK_RADIUS
		joystick_knob.position = JOYSTICK_CENTER + delta - Vector2(30.0, 30.0)
		_update_facing_from_joystick()

func _update_facing_from_joystick() -> void:
	if joystick_dir.length() < 0.2:
		return
	_set_facing("east" if joystick_dir.x >= 0.0 else "west")

# ── Physics ────────────────────────────────────────────────────────────────────
func _physics_process(delta : float) -> void:
	sword_cooldown    = maxf(sword_cooldown    - delta, 0.0)
	ability_cooldown  = maxf(ability_cooldown  - delta, 0.0)
	ult_cooldown      = maxf(ult_cooldown      - delta, 0.0)
	contact_hit_timer = maxf(contact_hit_timer - delta, 0.0)
	GameState.add_energy(delta * 12.0)

	if contact_hit_timer <= 0.0:
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if global_position.distance_to(enemy.global_position) < 30.0:
				GameState.take_damage(1)
				contact_hit_timer = 0.75
				break

	var cur_hearts : int = GameState.current_hearts
	if prev_hearts >= 0 and cur_hearts < prev_hearts:
		_on_hit(prev_hearts - cur_hearts)
	prev_hearts = cur_hearts

	if ult_aiming:
		if absf(joystick_dir.x) > 0.2:
			ult_aim_dir = Vector2.RIGHT if joystick_dir.x > 0.0 else Vector2.LEFT
		if aim_indicator:
			aim_indicator.scale.x = 1.0 if ult_aim_dir.x > 0.0 else -1.0

	if cast_looping:
		velocity = joystick_dir * GameState.get_character_speed() if touch_id != -1 else Vector2.ZERO
	elif touch_id != -1:
		velocity = joystick_dir * GameState.get_character_speed()
		if lpc_char and not lpc_char.is_busy():
			lpc_char.set_walking(true)
	else:
		velocity = Vector2.ZERO
		if lpc_char and not lpc_char.is_busy():
			lpc_char.set_walking(false)

	move_and_slide()
