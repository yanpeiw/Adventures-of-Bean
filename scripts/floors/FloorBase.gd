extends Node2D

const ROOM_W : int = 1280
const ROOM_H : int = 720
const WALL_T : int = 16

@onready var player          : CharacterBody2D = $Player
@onready var exit_portal     : Area2D          = $ExitPortal
@onready var portal_rect     : ColorRect       = $ExitPortal/PortalRect
@onready var portal_label    : Label           = $ExitPortal/PortalLabel
@onready var room_door       : Area2D          = $RoomDoor
@onready var door_rect       : ColorRect       = $RoomDoor/DoorRect
@onready var door_label      : Label           = $RoomDoor/DoorLabel
@onready var room_door2      : Area2D          = $RoomDoor2
@onready var door2_rect      : ColorRect       = $RoomDoor2/Door2Rect
@onready var door2_label     : Label           = $RoomDoor2/Door2Label
@onready var entrance_door   : Node2D          = $EntranceDoor
@onready var entrance_label  : Label           = $EntranceDoor/EntranceLabel
@onready var obstacle_layer  : Node2D          = $ObstacleLayer
@onready var enemy_layer     : Node2D          = $EnemyLayer
@onready var hud_floor       : Label           = $UILayer/HUD/FloorLabel
@onready var hud_hearts      : Label           = $UILayer/HUD/HeartsLabel
@onready var hud_energy      : Label           = $UILayer/HUD/EnergyLabel
@onready var exit_prompt     : Label           = $UILayer/ExitPrompt
@onready var slash_btn       : Button          = $UILayer/SlashBtn
@onready var ability_btn     : Button          = $UILayer/AbilityBtn
@onready var ult_btn         : Button          = $UILayer/UltimateBtn
@onready var mini_map        : Control         = $UILayer/MiniMap
@onready var menu_btn        : Button          = $UILayer/MenuBtn

var enemies_alive    : int     = 0
var current_wave     : int     = 0
var total_waves      : int     = 3
var door_dest        : int     = -1
var door2_dest       : int     = -1
var pause_overlay    : Control = null
var death_triggered  : bool    = false

func _ready() -> void:
	# Mark this room visited
	if not GameState.current_room in GameState.visited_rooms:
		GameState.visited_rooms.append(GameState.current_room)

	var cam : Camera2D = player.get_node("Camera2D")
	cam.limit_right  = ROOM_W
	cam.limit_bottom = ROOM_H

	obstacle_layer.z_index  = 3
	enemy_layer.z_index     = 3
	exit_portal.z_index     = 3
	room_door.z_index       = 3
	room_door2.z_index      = 3
	entrance_door.z_index   = 3

	_paint_floor()
	_update_hud()
	_brighten_walls()
	_add_wall_shadows()
	_init_door_silhouettes()
	_generate_obstacles()
	_spawn_enemies()

	exit_portal.monitoring = false
	room_door.monitoring   = false
	room_door2.monitoring  = false

	# Entrance door: hide in room 1
	if GameState.current_room <= 1:
		entrance_door.visible = false
	else:
		entrance_label.text = "< Room %d" % (GameState.current_room - 1)

	exit_portal.body_entered.connect(_on_exit_entered)
	room_door.body_entered.connect(_on_door_entered.bind(false))
	room_door2.body_entered.connect(_on_door_entered.bind(true))

	slash_btn.pressed.connect(func():   player.sword_slash())
	ability_btn.pressed.connect(func(): player.class_ability())
	ult_btn.button_down.connect(func(): player.ult_button_down())
	ult_btn.button_up.connect(func():   player.ult_button_up())

	mini_map.queue_redraw()

	menu_btn.pressed.connect(_toggle_pause)
	_build_pause_overlay()
	_style_hud()

func _process(_delta : float) -> void:
	_update_hud()
	if not death_triggered and GameState.current_hearts <= 0:
		death_triggered = true
		get_tree().change_scene_to_file("res://scenes/ui/DeathScreen.tscn")

func _update_hud() -> void:
	hud_floor.text  = "%s  —  Room %d / %d" % [
		GameState.get_floor_display_name(),
		GameState.current_room,
		GameState.get_floor_room_count()
	]
	hud_hearts.text = "❤  %d / %d" % [GameState.current_hearts, GameState.get_max_hearts()]
	hud_energy.text = "⚡ %.0f / %.0f" % [GameState.energy, GameState.max_energy]

	var ab_cost  : float = GameState.get_spell_stats().get("energy_cost", 999.0)
	var ult_cost : float = GameState.get_ultimate_stats().get("energy_cost", 999.0)
	ability_btn.modulate = Color.WHITE if GameState.energy >= ab_cost  else Color(0.5, 0.5, 0.5, 1.0)
	ult_btn.modulate     = Color.WHITE if GameState.energy >= ult_cost else Color(0.5, 0.5, 0.5, 1.0)

	if player.ability_cooldown > 0.0:
		ability_btn.text = "🔥 SKILL\n%.1fs" % player.ability_cooldown
	else:
		ability_btn.text = "🔥 SKILL"
	if player.ult_cooldown > 0.0:
		ult_btn.text = "✨ ULT\n%.1fs" % player.ult_cooldown
	else:
		ult_btn.text = "✨ ULT"

# ── HUD styling ──────────────────────────────────────────────────────────────
func _style_hud() -> void:
	# Dark stone backing behind HUD labels
	var hud_bg := ColorRect.new()
	hud_bg.color = Color(0.04, 0.03, 0.07, 0.82)
	hud_bg.size  = Vector2(260, 52)
	hud_bg.position = Vector2(0, 0)
	$UILayer/HUD.add_child(hud_bg)
	$UILayer/HUD.move_child(hud_bg, 0)

	# Style action buttons with rune-carved stone look
	_style_action_btn(slash_btn,   Color(0.55, 0.12, 0.12, 1), Color(0.90, 0.25, 0.25, 1))
	_style_action_btn(ability_btn, Color(0.12, 0.10, 0.45, 1), Color(0.45, 0.35, 0.90, 1))
	_style_action_btn(ult_btn,     Color(0.40, 0.28, 0.04, 1), Color(0.90, 0.68, 0.12, 1))

	# Style exit prompt
	exit_prompt.add_theme_color_override("font_color", Color(1.0, 0.88, 0.40, 1))
	exit_prompt.add_theme_font_size_override("font_size", 9)

	# Style minimap with dark frame
	var mm_bg := ColorRect.new()
	mm_bg.color         = Color(0.04, 0.03, 0.07, 0.80)
	mm_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mm_bg.offset_left   = -4
	mm_bg.offset_top    = -4
	mm_bg.offset_right  = 4
	mm_bg.offset_bottom = 4
	mini_map.add_child(mm_bg)
	mini_map.move_child(mm_bg, 0)

func _style_action_btn(btn : Button, bg : Color, border : Color) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color    = bg
	s.border_color = border
	s.border_width_left   = 2
	s.border_width_top    = 2
	s.border_width_right  = 2
	s.border_width_bottom = 2
	s.corner_radius_top_left     = 4
	s.corner_radius_top_right    = 4
	s.corner_radius_bottom_left  = 4
	s.corner_radius_bottom_right = 4
	s.content_margin_left   = 6.0
	s.content_margin_right  = 6.0
	s.content_margin_top    = 4.0
	s.content_margin_bottom = 4.0
	btn.add_theme_stylebox_override("normal",  s)
	btn.add_theme_stylebox_override("focus",   s)
	var sh := s.duplicate() as StyleBoxFlat
	sh.bg_color = sh.bg_color.lightened(0.15)
	btn.add_theme_stylebox_override("hover",   sh)
	var sp := s.duplicate() as StyleBoxFlat
	sp.bg_color = sp.bg_color.darkened(0.2)
	btn.add_theme_stylebox_override("pressed", sp)
	btn.add_theme_color_override("font_color", Color(1.0, 0.95, 0.80, 1))

# ── Wall & door init ─────────────────────────────────────────────────────────
func _add_wall_shadows() -> void:
	var wsl : Node2D = load("res://scripts/effects/WallShadowLayer.gd").new()
	wsl.set("room_w", ROOM_W)
	wsl.set("room_h", ROOM_H)
	wsl.set("wall_t", WALL_T)
	add_child(wsl)

func _brighten_walls() -> void:
	var wall_color : Color = Color(0.28, 0.22, 0.36, 1.0)
	$WallTop/WallTopRect.color       = wall_color
	$WallBottom/WallBottomRect.color = wall_color
	$WallLeft/WallLeftRect.color     = wall_color
	$WallRight/WallRightRect.color   = wall_color

func _init_door_silhouettes() -> void:
	var silhouette : Color = Color(0.20, 0.16, 0.28, 1.0)
	door_rect.color        = silhouette
	door2_rect.color       = silhouette
	door_label.text        = "Locked"
	door2_label.text       = "Locked"
	room_door2.visible     = true

# ── Floor tile painting ───────────────────────────────────────────────────────
const TILE_SIZE : int = 16

func _paint_floor() -> void:
	var tower_id  : String = GameState.selected_tower
	var theme     : String = GameState.get_floor_theme()
	var base_path : String = "res://art/tilesets/%s/%s/" % [tower_id, theme]
	var json_path : String = base_path + "metadata.json"
	var png_path  : String = base_path + "tileset.png"
	if not FileAccess.file_exists(json_path):
		base_path = "res://art/tilesets/%s/" % tower_id
		json_path  = base_path + "metadata.json"
		png_path   = base_path + "tileset.png"

	if not FileAccess.file_exists(json_path) or not FileAccess.file_exists(png_path):
		return

	var f := FileAccess.open(json_path, FileAccess.READ)
	if f == null:
		return
	var meta : Dictionary = JSON.parse_string(f.get_as_text())
	f.close()

	var floor_coord := Vector2i(-1, -1)
	for tile in meta["tileset_data"]["tiles"]:
		var c : Dictionary = tile["corners"]
		if c["NE"] == "lower" and c["NW"] == "lower" and c["SE"] == "lower" and c["SW"] == "lower":
			var bb : Dictionary = tile["bounding_box"]
			floor_coord = Vector2i(bb["x"] / TILE_SIZE, bb["y"] / TILE_SIZE)
			break

	if floor_coord.x < 0:
		return

	var ts  := TileSet.new()
	ts.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var src := TileSetAtlasSource.new()
	src.texture             = load(png_path) as Texture2D
	src.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for tx in 4:
		for ty in 4:
			src.create_tile(Vector2i(tx, ty))
	ts.add_source(src, 0)

	var tmap := TileMapLayer.new()
	tmap.tile_set       = ts
	tmap.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tmap.z_index        = 1   # above Background (z=0), below all game objects (z=3+)
	add_child(tmap)
	move_child(tmap, 1)

	var cols : int = ROOM_W / TILE_SIZE
	var rows : int = ROOM_H / TILE_SIZE
	for tx in cols:
		for ty in rows:
			tmap.set_cell(Vector2i(tx, ty), 0, floor_coord)

# ── Obstacle generation ───────────────────────────────────────────────────────
func _generate_obstacles() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(GameState.selected_tower + str(GameState.current_floor) + str(GameState.current_room) + "obs")
	var tc : Color = GameState.TOWERS.get(GameState.selected_tower, {}).get("color", Color(0.2, 0.16, 0.26))

	# Stone pillars
	var pillars : int = rng.randi_range(4, 7)
	for _i in pillars:
		var px : float = rng.randf_range(180.0, 1060.0)
		var py : float = rng.randf_range(WALL_T + 48.0, ROOM_H - WALL_T - 48.0)
		_add_pillar(Vector2(px, py), tc)

	# Rubble clusters
	var rubble : int = rng.randi_range(3, 5)
	for _i in rubble:
		var rx : float = rng.randf_range(200.0, 1040.0)
		var ry : float = rng.randf_range(WALL_T + 55.0, ROOM_H - WALL_T - 55.0)
		var pieces : int = rng.randi_range(2, 3)
		for _j in pieces:
			var ox : float = rng.randf_range(-14.0, 14.0)
			var oy : float = rng.randf_range(-10.0, 10.0)
			var w  : float = rng.randf_range(16.0, 34.0)
			var h  : float = rng.randf_range(12.0, 28.0)
			_add_rubble_piece(Vector2(rx + ox, ry + oy), w, h, tc)

	# Horizontal and vertical wall segments
	var segments : int = rng.randi_range(3, 5)
	for _i in segments:
		var wx : float = rng.randf_range(240.0, 960.0)
		var wy : float = rng.randf_range(WALL_T + 60.0, ROOM_H - WALL_T - 60.0)
		_add_wall_segment(Vector2(wx, wy), rng.randi() % 2 == 0, tc)

func _add_pillar(pos : Vector2, tc : Color) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	obstacle_layer.add_child(body)

	var s : float = 18.0
	var shadow := ColorRect.new()
	shadow.color    = Color(0.0, 0.0, 0.0, 0.45)
	shadow.size     = Vector2(s + 10, s + 6)
	shadow.position = Vector2(-s * 0.5 + 5, -s * 0.5 + 8)
	shadow.z_index  = -1
	body.add_child(shadow)
	# Outer border
	var outer := ColorRect.new()
	outer.color = tc.lightened(0.12)
	outer.size = Vector2(s, s)
	outer.position = Vector2(-s * 0.5, -s * 0.5)
	body.add_child(outer)
	# Inner stone
	var inner := ColorRect.new()
	inner.color = tc.darkened(0.45)
	inner.size = Vector2(s - 4, s - 4)
	inner.position = Vector2(-s * 0.5 + 2, -s * 0.5 + 2)
	body.add_child(inner)
	# Center detail
	var dot := ColorRect.new()
	dot.color = tc.darkened(0.6)
	dot.size = Vector2(s - 10, s - 10)
	dot.position = Vector2(-s * 0.5 + 5, -s * 0.5 + 5)
	body.add_child(dot)

	var cshape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(s, s)
	cshape.shape = rs
	body.add_child(cshape)

func _add_rubble_piece(pos : Vector2, w : float, h : float, tc : Color) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	obstacle_layer.add_child(body)

	var shadow := ColorRect.new()
	shadow.color    = Color(0.0, 0.0, 0.0, 0.40)
	shadow.size     = Vector2(w + 8, h + 6)
	shadow.position = Vector2(-w * 0.5 + 5, -h * 0.5 + 7)
	shadow.z_index  = -1
	body.add_child(shadow)

	var rect := ColorRect.new()
	rect.color = tc.darkened(0.30)
	rect.size = Vector2(w, h)
	rect.position = Vector2(-w * 0.5, -h * 0.5)
	body.add_child(rect)
	# Highlight edge
	var hl := ColorRect.new()
	hl.color = tc.lightened(0.08)
	hl.size = Vector2(w, 2)
	hl.position = Vector2(-w * 0.5, -h * 0.5)
	body.add_child(hl)

	var cshape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(w, h)
	cshape.shape = rs
	body.add_child(cshape)

func _add_wall_segment(pos : Vector2, horizontal : bool, tc : Color) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	obstacle_layer.add_child(body)

	var w : float = 100.0 if horizontal else 16.0
	var h : float = 16.0  if horizontal else 88.0

	var shadow := ColorRect.new()
	shadow.color    = Color(0.0, 0.0, 0.0, 0.40)
	shadow.size     = Vector2(w + 10, h + 8)
	shadow.position = Vector2(-w * 0.5 + 6, -h * 0.5 + 8)
	shadow.z_index  = -1
	body.add_child(shadow)

	var rect := ColorRect.new()
	rect.color = tc.darkened(0.38)
	rect.size = Vector2(w, h)
	rect.position = Vector2(-w * 0.5, -h * 0.5)
	body.add_child(rect)
	# Top/left highlight stripe
	var hl := ColorRect.new()
	hl.color = tc.lightened(0.14)
	hl.size  = Vector2(w if horizontal else 3, 3 if horizontal else h)
	hl.position = Vector2(-w * 0.5, -h * 0.5)
	body.add_child(hl)

	var cshape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(w, h)
	cshape.shape = rs
	body.add_child(cshape)

# ── Enemy spawning — 3-wave system ───────────────────────────────────────────
func _spawn_enemies() -> void:
	if GameState.is_boss_floor() and GameState.is_last_room():
		total_waves = 1
	current_wave = 0
	_begin_next_wave()

func _begin_next_wave() -> void:
	current_wave += 1
	var pool : Array = GameState.get_tower_enemy_pool()
	if pool.is_empty():
		_unlock_exit()
		return

	var rng := RandomNumberGenerator.new()
	rng.seed = hash(GameState.selected_tower + str(GameState.current_floor)
		+ str(GameState.current_room) + "enm" + str(current_wave))

	var count : int = 10
	if GameState.is_boss_floor() and GameState.is_last_room():
		count = 1

	for _i in count:
		var ex  : float  = rng.randf_range(350.0, 950.0)
		var ey  : float  = rng.randf_range(WALL_T + 48.0, ROOM_H - WALL_T - 48.0)
		var eid : String = pool[rng.randi() % pool.size()]
		_spawn_enemy(eid, Vector2(ex, ey))

	enemies_alive = count

func _spawn_enemy(enemy_id : String, pos : Vector2) -> void:
	var data    : Dictionary = GameState.get_scaled_enemy(enemy_id)
	var is_boss : bool       = GameState.is_boss_floor() and GameState.is_last_room()

	var body := CharacterBody2D.new()
	body.position = pos
	body.set_meta("enemy_data", data)
	body.set_meta("is_boss",    is_boss)
	body.set_script(load("res://scripts/enemies/EnemySimple.gd"))
	enemy_layer.add_child(body)
	body.tree_exited.connect(_on_enemy_died)

func _show_wave_warning() -> void:
	var ui : CanvasLayer = $UILayer
	var lbl := Label.new()
	lbl.text = "⚠  MORE ENEMIES INCOMING!  ⚠"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.18, 0.18, 1))
	lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	lbl.offset_left  = -200.0
	lbl.offset_right =  200.0
	lbl.offset_top   = -16.0
	lbl.offset_bottom = 16.0
	ui.add_child(lbl)

	var t := create_tween()
	for _i in 5:
		t.tween_property(lbl, "modulate:a", 0.0, 0.14)
		t.tween_property(lbl, "modulate:a", 1.0, 0.14)
	t.tween_property(lbl, "modulate:a", 0.0, 0.28)
	t.tween_callback(lbl.queue_free)
	t.tween_callback(_begin_next_wave)

# ── Exit / door unlock ────────────────────────────────────────────────────────
func _on_enemy_died() -> void:
	enemies_alive -= 1
	if enemies_alive > 0:
		return
	if current_wave < total_waves:
		_show_wave_warning()
	else:
		_unlock_exit()

func _unlock_exit() -> void:
	var show_upgrade : bool = (GameState.current_room % 3 == 0) or GameState.is_last_room()
	if show_upgrade:
		_show_upgrade_screen()
	else:
		_open_exits()

func _open_exits() -> void:
	var exits : Array = GameState.get_room_exits(GameState.current_room)

	if exits.is_empty():
		portal_rect.color      = Color(0.784, 0.573, 0.165, 1)
		portal_label.text      = "Exit Floor"
		exit_portal.monitoring = true
		exit_prompt.text       = "Floor exit open!"
		exit_prompt.show()

	elif exits.size() == 1:
		door_dest              = exits[0]
		room_door.position     = Vector2(1248, 360)
		door_rect.color        = Color(0.25, 0.78, 0.38, 1)
		door_label.text        = "Room %d →" % door_dest
		room_door.monitoring   = true
		exit_prompt.text       = "Door unlocked!"
		exit_prompt.show()

	else:
		door_dest              = exits[0]
		room_door.position     = Vector2(1248, 230)
		door_rect.color        = Color(0.25, 0.78, 0.38, 1)
		door_label.text        = "→ %d" % door_dest
		room_door.monitoring   = true

		door2_dest             = exits[1]
		room_door2.visible     = true
		room_door2.position    = Vector2(1248, 490)
		door2_rect.color       = Color(0.30, 0.55, 0.80, 1)
		door2_label.text       = "→ %d" % door2_dest
		room_door2.monitoring  = true

		exit_prompt.text       = "Doors unlocked! Choose a path."
		exit_prompt.show()

func _show_upgrade_screen() -> void:
	var ui : CanvasLayer = $UILayer
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.80)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.offset_left   = -220.0
	vbox.offset_right  =  220.0
	vbox.offset_top    = -140.0
	vbox.offset_bottom =  140.0
	vbox.add_theme_constant_override("separation", 14)
	overlay.add_child(vbox)

	var title := Label.new()
	title.text = "✦  CHOOSE AN UPGRADE  ✦"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 9)
	title.modulate = Color(1.0, 0.88, 0.32, 1.0)
	vbox.add_child(title)

	var upgrades : Array = [
		{
			"label": "+1 Max Heart\nRestores 1 HP too",
			"color": Color(0.55, 0.10, 0.10, 0.92),
			"border": Color(0.90, 0.28, 0.28, 1.0),
			"type": "heart",
		},
		{
			"label": "+1 Defense\nBlock 1 dmg per hit",
			"color": Color(0.10, 0.22, 0.50, 0.92),
			"border": Color(0.35, 0.60, 1.00, 1.0),
			"type": "defense",
		},
		{
			"label": "+25% Attack Speed\nSlash faster",
			"color": Color(0.42, 0.28, 0.04, 0.92),
			"border": Color(0.95, 0.72, 0.14, 1.0),
			"type": "attack_speed",
		},
	]

	for upg in upgrades:
		var btn := Button.new()
		btn.text = upg["label"]
		btn.custom_minimum_size = Vector2(440, 52)
		btn.add_theme_font_size_override("font_size", 8)

		var s := StyleBoxFlat.new()
		s.bg_color     = upg["color"]
		s.border_color = upg["border"]
		s.set_border_width_all(2)
		s.set_corner_radius_all(5)
		s.content_margin_left = 10; s.content_margin_right  = 10
		s.content_margin_top  = 6;  s.content_margin_bottom = 6
		btn.add_theme_stylebox_override("normal",  s)
		btn.add_theme_stylebox_override("focus",   s)
		var sh := s.duplicate() as StyleBoxFlat
		sh.bg_color = sh.bg_color.lightened(0.18)
		btn.add_theme_stylebox_override("hover",   sh)
		btn.add_theme_stylebox_override("pressed", sh)

		var upg_t : String = upg["type"]
		btn.pressed.connect(func():
			_apply_upgrade(upg_t)
			overlay.queue_free()
			_open_exits()
		)
		vbox.add_child(btn)

	ui.add_child(overlay)

func _apply_upgrade(upg_type : String) -> void:
	match upg_type:
		"heart":
			GameState.bonus_max_hearts += 1
			GameState.heal(1)
		"defense":
			GameState.defense += 1
		"attack_speed":
			GameState.attack_speed_bonus += 0.25
	GameState.save()

func _on_door_entered(body : Node, is_door2 : bool) -> void:
	if body != player:
		return
	var dest : int = door2_dest if is_door2 else door_dest
	if dest < 1:
		return
	GameState.go_to_room(dest)
	get_tree().change_scene_to_file("res://scenes/floors/HallwayScene.tscn")

func _on_exit_entered(body : Node) -> void:
	if body != player:
		return
	if GameState.current_floor >= GameState.get_tower_floor_count():
		GameState.complete_tower_run()
		get_tree().change_scene_to_file("res://scenes/hub/HubScene.tscn")
	else:
		GameState.advance_floor()
		get_tree().change_scene_to_file("res://scenes/floors/FloorBase.tscn")

# ── Pause / exit menu ─────────────────────────────────────────────────────────
func _build_pause_overlay() -> void:
	var ui : CanvasLayer = $UILayer

	pause_overlay = Control.new()
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.visible = false

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.add_child(dim)

	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(240, 0)
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.offset_left  = -120.0
	box.offset_right =  120.0
	box.offset_top   = -60.0
	box.offset_bottom = 60.0
	box.add_theme_constant_override("separation", 16)
	pause_overlay.add_child(box)

	var lbl := Label.new()
	lbl.text = "— Paused —"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 16)
	box.add_child(lbl)

	var resume := Button.new()
	resume.text = "Resume"
	resume.custom_minimum_size = Vector2(240, 40)
	resume.pressed.connect(_toggle_pause)
	box.add_child(resume)

	var exit_btn := Button.new()
	exit_btn.text = "Exit to Hub"
	exit_btn.custom_minimum_size = Vector2(240, 40)
	exit_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/hub/HubScene.tscn"))
	box.add_child(exit_btn)

	ui.add_child(pause_overlay)

func _toggle_pause() -> void:
	pause_overlay.visible = not pause_overlay.visible
