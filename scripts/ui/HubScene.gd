extends Node2D

@onready var player           : CharacterBody2D = $Player
@onready var player_rect      : ColorRect       = $Player/PlayerRect
@onready var camera           : Camera2D        = $Player/Camera2D
@onready var interact_prompt  : Label           = $UILayer/InteractPrompt
@onready var gate             : Area2D          = $Gate
@onready var shrine           : Area2D          = $Shrine
@onready var merchant         : Area2D          = $Merchant
@onready var merchant_sprite  : Sprite2D        = $Merchant/MerchantSprite
@onready var joystick_base    : Control         = $UILayer/JoystickBase
@onready var joystick_knob    : Control         = $UILayer/JoystickKnob

const SPEED           : float   = 200.0
const INTERACT_RANGE  : float   = 120.0
const JOYSTICK_CENTER : Vector2 = Vector2(80.0, 400.0)
const JOYSTICK_RADIUS : float   = 50.0

var touch_id             : int      = -1
var joystick_dir         : Vector2  = Vector2.ZERO
var nearest_interactable : Area2D   = null
var char_overlay         : Control  = null
var chibi_char           : Node2D   = null

func _ready() -> void:
	interact_prompt.hide()
	merchant_sprite.hide()
	player_rect.hide()
	_add_merchant_rect()
	_build_joystick_visuals()
	_build_switch_char_btn()
	_build_hub_chibi()

func _build_hub_chibi() -> void:
	if chibi_char and is_instance_valid(chibi_char):
		chibi_char.queue_free()
	chibi_char = load("res://scripts/player/ChibiCharacter.gd").new()
	player.add_child(chibi_char)
	chibi_char.setup(GameState.selected_character)
	var shadow : Node2D = load("res://scripts/effects/ShadowBlob.gd").new()
	shadow.position = Vector2(4.0, 17.0)
	shadow.set("blob_w", 30.0)
	shadow.set("blob_h", 10.0)
	player.add_child(shadow)
	player.move_child(shadow, 0)

func _add_merchant_rect() -> void:
	var r := ColorRect.new()
	r.color           = Color(0.55, 0.35, 0.15, 1.0)
	r.size            = Vector2(50, 70)
	r.position        = Vector2(-25, -35)
	merchant.add_child(r)
	var lbl := Label.new()
	lbl.text = "Merchant"
	lbl.position = Vector2(-30, -55)
	lbl.add_theme_font_size_override("font_size", 11)
	merchant.add_child(lbl)

# ── Switch Character button ────────────────────────────────────────────────────
func _build_switch_char_btn() -> void:
	var btn := Button.new()
	btn.text = "Switch\nChar"
	btn.custom_minimum_size = Vector2(84, 84)

	var s := StyleBoxFlat.new()
	s.bg_color    = Color(0.16, 0.08, 0.28, 0.92)
	s.border_color = Color(0.65, 0.38, 1.00)
	s.border_width_left   = 3
	s.border_width_right  = 3
	s.border_width_top    = 3
	s.border_width_bottom = 3
	s.corner_radius_top_left     = 42
	s.corner_radius_top_right    = 42
	s.corner_radius_bottom_left  = 42
	s.corner_radius_bottom_right = 42
	btn.add_theme_stylebox_override("normal", s)
	btn.add_theme_color_override("font_color", Color(0.90, 0.75, 1.00))
	btn.add_theme_font_size_override("font_size", 11)

	btn.anchor_left   = 1.0
	btn.anchor_right  = 1.0
	btn.anchor_top    = 1.0
	btn.anchor_bottom = 1.0
	btn.offset_left   = -102.0
	btn.offset_right  = -18.0
	btn.offset_top    = -102.0
	btn.offset_bottom = -18.0

	btn.pressed.connect(_show_char_select)
	$UILayer.add_child(btn)

# ── Character select overlay ───────────────────────────────────────────────────
func _show_char_select() -> void:
	if char_overlay:
		return

	char_overlay = Control.new()
	char_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.78)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	char_overlay.add_child(dim)

	var panel := PanelContainer.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color    = Color(0.07, 0.04, 0.13, 0.97)
	ps.border_color = Color(0.55, 0.32, 0.88)
	ps.border_width_left   = 2
	ps.border_width_right  = 2
	ps.border_width_top    = 2
	ps.border_width_bottom = 2
	ps.corner_radius_top_left    = 14
	ps.corner_radius_top_right   = 14
	ps.corner_radius_bottom_left = 14
	ps.corner_radius_bottom_right = 14
	panel.add_theme_stylebox_override("panel", ps)
	panel.anchor_left   = 0.5
	panel.anchor_right  = 0.5
	panel.anchor_top    = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left   = -190
	panel.offset_right  = 190
	panel.offset_top    = -190
	panel.offset_bottom = 190
	char_overlay.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Select Character"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.92, 0.80, 0.32))
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	for cid in ["warrior", "healer", "wizard"]:
		vbox.add_child(_build_char_row(cid))

	var close_btn := Button.new()
	close_btn.text = "Cancel"
	close_btn.add_theme_color_override("font_color", Color(0.65, 0.55, 0.80))
	close_btn.pressed.connect(func():
		char_overlay.queue_free()
		char_overlay = null
	)
	vbox.add_child(close_btn)

	$UILayer.add_child(char_overlay)

func _build_char_row(cid : String) -> HBoxContainer:
	var cdata    : Dictionary = GameState.CHARACTERS.get(cid, {})
	var is_sel   : bool       = cid == GameState.selected_character
	var unlocked : bool       = cid in GameState.unlocked_characters

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	var thumb_path : String = "res://art/characters/%s/east.png" % cid
	if ResourceLoader.exists(thumb_path):
		var tr := TextureRect.new()
		tr.texture             = load(thumb_path)
		tr.texture_filter      = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.expand_mode         = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode        = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.custom_minimum_size = Vector2(44, 44)
		hbox.add_child(tr)

	var label_text : String = "%s\n❤ %d  %s" % [
		cdata.get("name", cid.capitalize()),
		cdata.get("max_hearts", 0),
		("[Selected]" if is_sel else ("Locked" if not unlocked else "Tap to Select"))
	]
	var btn := Button.new()
	btn.text                  = label_text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.disabled              = not unlocked

	var bs := StyleBoxFlat.new()
	bs.corner_radius_top_left    = 6
	bs.corner_radius_top_right   = 6
	bs.corner_radius_bottom_left = 6
	bs.corner_radius_bottom_right = 6
	bs.border_width_left   = 2
	bs.border_width_right  = 2
	bs.border_width_top    = 2
	bs.border_width_bottom = 2
	if is_sel:
		bs.bg_color    = Color(0.32, 0.14, 0.52, 0.95)
		bs.border_color = Color(0.85, 0.55, 1.00)
		btn.add_theme_color_override("font_color", Color(0.95, 0.85, 0.35))
	else:
		bs.bg_color    = Color(0.11, 0.07, 0.19, 0.90)
		bs.border_color = Color(0.38, 0.22, 0.62)
		btn.add_theme_color_override("font_color", Color(0.78, 0.70, 0.90))
	btn.add_theme_stylebox_override("normal", bs)

	btn.pressed.connect(func():
		GameState.select_character(cid)
		if char_overlay:
			char_overlay.queue_free()
			char_overlay = null
		_build_hub_chibi()
	)
	hbox.add_child(btn)
	return hbox

# ── Joystick visuals ───────────────────────────────────────────────────────────
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

# ── Input ──────────────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if touch_id == -1 and event.position.x < 427.0:
				touch_id     = event.index
				joystick_dir = Vector2.ZERO
				_reset_knob()
				get_viewport().set_input_as_handled()
		else:
			if event.index == touch_id:
				touch_id        = -1
				joystick_dir    = Vector2.ZERO
				player.velocity = Vector2.ZERO
				_reset_knob()
				get_viewport().set_input_as_handled()
	if event is InputEventScreenDrag and event.index == touch_id:
		var delta : Vector2 = event.position - JOYSTICK_CENTER
		if delta.length() > JOYSTICK_RADIUS:
			delta = delta.normalized() * JOYSTICK_RADIUS
		joystick_dir           = delta / JOYSTICK_RADIUS
		joystick_knob.position = JOYSTICK_CENTER + delta - Vector2(30.0, 30.0)
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if nearest_interactable != null:
			_navigate(nearest_interactable)

# ── Physics ────────────────────────────────────────────────────────────────────
func _physics_process(_delta: float) -> void:
	_handle_movement()
	_check_interact_range()
	merchant_sprite.flip_h = player.global_position.x < merchant.global_position.x

func _handle_movement() -> void:
	if touch_id == -1:
		player.velocity = Vector2.ZERO
	else:
		player.velocity = joystick_dir * SPEED
	player.move_and_slide()
	if chibi_char:
		var moving : bool = player.velocity.length() > 10.0
		chibi_char.set_walking(moving)
		if moving:
			chibi_char.set_facing("east" if player.velocity.x >= 0.0 else "west")
	var screen_pos : Vector2 = get_viewport().get_canvas_transform() * player.global_position
	interact_prompt.position = screen_pos + Vector2(-60, -80)

func _check_interact_range() -> void:
	var closest      : Area2D = null
	var closest_dist : float  = INTERACT_RANGE
	for area in [gate, shrine, merchant]:
		var dist : float = player.global_position.distance_to(area.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest      = area
	nearest_interactable = closest
	if nearest_interactable != null:
		interact_prompt.text = _prompt_label(nearest_interactable)
		interact_prompt.show()
	else:
		interact_prompt.hide()

func _prompt_label(area : Area2D) -> String:
	if area == gate:       return "Tap to Enter the Spire"
	elif area == shrine:   return "Tap to visit Shrine"
	elif area == merchant: return "Tap to visit Merchant"
	return "Tap to Interact"

func _navigate(area : Area2D) -> void:
	if area == gate:
		get_tree().change_scene_to_file("res://scenes/ui/TowerSelect.tscn")
	elif area == shrine:
		get_tree().change_scene_to_file("res://scenes/ui/SkillTreeScreen.tscn")
	elif area == merchant:
		get_tree().change_scene_to_file("res://scenes/ui/ShopScreen.tscn")
