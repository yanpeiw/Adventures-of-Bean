extends CharacterBody2D

const SPRITE_FOLDERS : Dictionary = {
	"stone_shambler"  : "stone_shambler",
	"ash_wraith"      : "ash_wraith",
	"fungal_crawler"  : "fungal_crawler",
	"brass_automaton" : "brass_automaton",
	"drowned_soldier" : "drowned_soldier",
}

const WALK_FPS   : float = 8.0
const ATTACK_FPS : float = 10.0

const SPRITE_SCALES : Dictionary = {
	"ash_wraith"     : 0.78,
	"stone_shambler" : 1.5,
}

const STANDOFF_RANGES : Dictionary = {
	"stone_shambler"  : 220.0,
	"ash_wraith"      : 165.0,
	"fungal_crawler"  : 110.0,
	"brass_automaton" : 180.0,
	"drowned_soldier" : 120.0,
}

const ATTACK_COOLDOWNS : Dictionary = {
	"stone_shambler"  : 2.2,
	"ash_wraith"      : 1.1,
	"fungal_crawler"  : 1.8,
	"brass_automaton" : 2.6,
	"drowned_soldier" : 1.4,
}

const PROJ_COLORS : Dictionary = {
	"stone_shambler"  : Color(0.65, 0.55, 0.40, 1.0),
	"ash_wraith"      : Color(0.70, 0.82, 1.00, 1.0),
	"fungal_crawler"  : Color(0.30, 0.82, 0.20, 1.0),
	"brass_automaton" : Color(1.00, 0.65, 0.10, 1.0),
	"drowned_soldier" : Color(0.25, 0.50, 0.85, 1.0),
}

const PROJ_SPEEDS : Dictionary = {
	"stone_shambler"  : 160.0,
	"ash_wraith"      : 240.0,
	"fungal_crawler"  : 175.0,
	"brass_automaton" : 280.0,
	"drowned_soldier" : 200.0,
}

var hp       : int    = 3
var damage   : int    = 1
var speed    : float  = 60.0
var is_boss  : bool   = false
var enemy_id : String = ""
var player   : Node2D = null

# Sprites — only east loaded; west = flip_h
var textures    : Dictionary = {}   # "east" → Texture2D
var anim_frames : Dictionary = {}   # anim → "east" → [Texture2D, …]
var facing      : String     = "east"
var sprite_node : Sprite2D   = null

# Animation state
var frame_idx   : int   = 0
var frame_timer : float = 0.0
var anim_locked : bool  = false

var walk_tween    : Tween  = null
var sword_visual  : Node2D = null
var attack_timer  : float  = 1.0

# ── Setup ──────────────────────────────────────────────────────────────────────
func _ready() -> void:
	var data : Dictionary = get_meta("enemy_data", {})
	hp       = data.get("hp",     3)
	damage   = data.get("damage", 1)
	speed    = data.get("speed",  60.0)
	enemy_id = data.get("id",     "")
	is_boss  = get_meta("is_boss", false)
	if is_boss:
		speed *= 0.65
	add_to_group("enemies")
	z_index  = 3   # shadow (z=-1 rel → 2) above tilemap (1); sprite (z=0 rel → 3) above shadow

	_build_collision()
	_load_sprites()
	_build_visual()

	if is_boss:
		_activate()
	else:
		visible = false
		set_physics_process(false)
		var effect : Node2D = load("res://scripts/effects/SpawnEffect.gd").new()
		get_parent().add_child(effect)
		effect.global_position = global_position
		effect.start(_activate)

func _build_collision() -> void:
	var sz     : float = 44.0 if is_boss else 26.0
	var cshape := CollisionShape2D.new()
	var rs     := RectangleShape2D.new()
	rs.size     = Vector2(sz, sz)
	cshape.shape = rs
	add_child(cshape)

func _load_sprites() -> void:
	var folder : String = SPRITE_FOLDERS.get(enemy_id, "")
	if folder.is_empty():
		return

	# Only load east sprite; west = flip_h
	var path := "res://art/characters/%s/east.png" % folder
	if ResourceLoader.exists(path):
		textures["east"] = load(path)

	# Animation frames (walk, attack) — east only
	for anim in ["walk", "attack"]:
		anim_frames[anim] = {}
		var frames : Array = []
		var i := 0
		while true:
			var fpath := "res://art/characters/%s/%s/east_%04d.png" % [folder, anim, i]
			if ResourceLoader.exists(fpath):
				frames.append(load(fpath))
				i += 1
			else:
				break
		if frames.size() > 0:
			anim_frames[anim]["east"] = frames

func _has_anim(anim : String) -> bool:
	return anim_frames.has(anim) \
		and anim_frames[anim].has("east") \
		and anim_frames[anim]["east"].size() > 0

func _build_visual() -> void:
	if textures.has("east"):
		sprite_node                = Sprite2D.new()
		sprite_node.texture        = textures["east"]
		sprite_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var base_scale : float = SPRITE_SCALES.get(enemy_id, 2.2)
		sprite_node.scale = Vector2(5.0, 5.0) if is_boss else Vector2(base_scale, base_scale)
		add_child(sprite_node)
	else:
		var sz    : float = 48.0 if is_boss else 32.0
		var color : Color = GameState.ENEMIES.get(enemy_id, {}).get("color", Color.RED)
		var rect  := ColorRect.new()
		rect.color    = color
		rect.size     = Vector2(sz, sz)
		rect.position = Vector2(-sz * 0.5, -sz * 0.5)
		add_child(rect)

	if enemy_id == "drowned_soldier":
		_add_sword_visual()

	_add_shadow()

func _add_shadow() -> void:
	var shadow : Node2D = load("res://scripts/effects/ShadowBlob.gd").new()
	shadow.position = Vector2(4.0, 44.0) if is_boss else Vector2(4.0, 20.0)
	shadow.set("blob_w", 60.0 if is_boss else 32.0)
	shadow.set("blob_h", 20.0 if is_boss else 10.0)
	add_child(shadow)
	move_child(shadow, 0)

func _add_sword_visual() -> void:
	sword_visual = load("res://scripts/enemies/EnemySword.gd").new()
	sword_visual.position = Vector2(14.0, 2.0)
	sword_visual.z_index  = 1
	add_child(sword_visual)

func _activate() -> void:
	visible = true
	set_physics_process(true)
	if not _has_anim("walk"):
		_start_walk_bob()
	call_deferred("_find_player")

# ── Walk bob fallback ──────────────────────────────────────────────────────────
func _start_walk_bob() -> void:
	if walk_tween and walk_tween.is_valid():
		return
	var target : Node = sprite_node
	if target == null:
		for c in get_children():
			if c is ColorRect:
				target = c
				break
	if target == null:
		return
	var base_y : float = target.position.y
	walk_tween = create_tween().set_loops()
	walk_tween.tween_property(target, "position:y", base_y - 4.0, 0.22)
	walk_tween.tween_property(target, "position:y", base_y,       0.22)

func _stop_walk_bob() -> void:
	if walk_tween and walk_tween.is_valid():
		walk_tween.kill()
		walk_tween = null

# ── Frame animation ────────────────────────────────────────────────────────────
func _tick_walk(delta : float) -> void:
	if not _has_anim("walk") or sprite_node == null:
		return
	frame_timer += delta
	if frame_timer >= 1.0 / WALK_FPS:
		frame_timer  = 0.0
		var fs : Array = anim_frames["walk"]["east"]
		frame_idx           = (frame_idx + 1) % fs.size()
		sprite_node.texture = fs[frame_idx]

func _play_attack_anim(on_fire : Callable = Callable(), fire_on_frame : int = -1) -> void:
	if anim_locked or not _has_anim("attack") or sprite_node == null:
		return
	anim_locked = true
	_stop_walk_bob()
	var fs        : Array = anim_frames["attack"]["east"]
	var frame_dur : float = 1.0 / ATTACK_FPS
	var trigger   : int   = fire_on_frame if fire_on_frame >= 0 else fs.size() - 1
	var t         := create_tween()
	for i in fs.size():
		var tex : Texture2D = fs[i]
		t.tween_callback(func(): sprite_node.texture = tex)
		if i == trigger and on_fire.is_valid():
			t.tween_callback(on_fire)
		t.tween_interval(frame_dur)
	t.tween_callback(func():
		anim_locked = false
		if textures.has("east"):
			sprite_node.texture = textures["east"]
	)

# ── AI ─────────────────────────────────────────────────────────────────────────
func _find_player() -> void:
	var nodes := get_tree().get_nodes_in_group("player")
	if nodes.size() > 0:
		player = nodes[0]

func _physics_process(delta : float) -> void:
	if player == null:
		_find_player()
		return

	attack_timer = maxf(attack_timer - delta, 0.0)

	var diff     : Vector2 = player.global_position - global_position
	var dist     : float   = diff.length()
	var standoff : float   = STANDOFF_RANGES.get(enemy_id, 120.0)

	if dist <= standoff + 24.0:
		velocity = Vector2.ZERO
		_set_facing("east" if diff.x >= 0.0 else "west")
		if attack_timer <= 0.0:
			attack_timer = ATTACK_COOLDOWNS.get(enemy_id, 2.0)
			_do_attack()
	else:
		velocity = diff.normalized() * speed
		_set_facing("east" if diff.x >= 0.0 else "west")
		if not anim_locked:
			if _has_anim("walk"):
				_tick_walk(delta)

	move_and_slide()

func _set_facing(dir : String) -> void:
	if dir == facing:
		return
	facing      = dir
	frame_idx   = 0
	frame_timer = 0.0
	if sprite_node != null:
		sprite_node.flip_h = (dir == "west")
		if not anim_locked and textures.has("east"):
			sprite_node.texture = textures["east"]
	if sword_visual:
		var s : float = -1.0 if dir == "west" else 1.0
		sword_visual.scale.x    = s
		sword_visual.position.x = 14.0 * s

func _do_attack() -> void:
	if player == null:
		return
	if enemy_id == "ash_wraith":
		_play_attack_anim(func(): _attack_triple_burst())
	elif enemy_id == "stone_shambler":
		if _has_anim("attack"):
			_play_attack_anim(func(): _attack_laser_beam(), 5)
		else:
			_attack_laser_beam()
	else:
		_play_attack_anim()
		if   enemy_id == "fungal_crawler":  _attack_spore()
		elif enemy_id == "brass_automaton": _attack_lightning_ball()
		elif enemy_id == "drowned_soldier": _attack_water_slash()

func _spawn_proj(script_path : String) -> Node2D:
	var proj : Node2D = load(script_path).new()
	get_parent().add_child(proj)
	proj.global_position = global_position
	return proj

func _dir_to_player() -> Vector2:
	return (player.global_position - global_position).normalized()

func _attack_boulder() -> void:
	var p := _spawn_proj("res://scripts/enemies/BoulderProjectile.gd")
	p.direction = _dir_to_player()
	p.damage    = damage

func _attack_laser_beam() -> void:
	var p := _spawn_proj("res://scripts/enemies/LaserBeam.gd")
	p.direction = _dir_to_player()
	p.damage    = damage + 1

func _attack_triple_burst() -> void:
	var hand_offset := Vector2(18.0, -11.0) * (1.0 if facing == "east" else -1.0)
	var spawn_pos   := global_position + hand_offset
	var base_angle  : float = _dir_to_player().angle()
	for spread in [-20.0, 0.0, 20.0]:
		var p := _spawn_proj("res://scripts/enemies/AuraBurst.gd")
		p.global_position = spawn_pos
		p.direction = Vector2.from_angle(base_angle + deg_to_rad(spread))
		p.damage    = damage

func _attack_spore() -> void:
	var p := _spawn_proj("res://scripts/enemies/SporeProjectile.gd")
	p.direction = _dir_to_player()
	p.damage    = damage

func _attack_lightning_ball() -> void:
	var p := _spawn_proj("res://scripts/enemies/LightningBall.gd")
	p.direction = _dir_to_player()
	p.damage    = damage + 1

func _attack_water_slash() -> void:
	var p := _spawn_proj("res://scripts/enemies/WaterSlash.gd")
	p.direction = _dir_to_player()
	p.damage    = damage

# ── Damage ─────────────────────────────────────────────────────────────────────
func take_damage(amount : int) -> void:
	_spawn_damage_number(amount)
	hp -= amount
	if hp <= 0:
		var gold : int = randi_range(2, 5) + (8 if is_boss else 0)
		GameState.add_gold(gold)
		queue_free()
		return
	var t := create_tween()
	t.tween_property(self, "modulate", Color(2.0, 0.3, 0.3), 0.05)
	t.tween_property(self, "modulate", Color.WHITE,           0.12)

func _spawn_damage_number(amount : int) -> void:
	var par : Node = get_parent()
	if par == null:
		return
	var dn : Node2D = load("res://scripts/effects/DamageNumber.gd").new()
	par.add_child(dn)
	dn.global_position = global_position + Vector2(randf_range(-8.0, 8.0), -28.0)
	dn.setup(amount)
