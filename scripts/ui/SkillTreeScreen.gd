extends Control
## Skill tree screen — accessible from the Shrine in the hub.

const NODE_W : float = 130.0
const NODE_H : float = 48.0

# Absolute screen positions (center of each node box), 854×480 viewport.
const POSITIONS : Dictionary = {
	"warrior": {
		"eq_dmg_1":    Vector2(427, 115),
		"eq_dmg_2":    Vector2(185, 222),
		"eq_radius_1": Vector2(427, 222),
		"eq_cooldown": Vector2(670, 222),
		"eq_radius_2": Vector2(427, 329),
		"eq_stun":     Vector2(310, 400),
	},
	"healer": {
		"ts_dmg_1":    Vector2(427, 115),
		"ts_dmg_2":    Vector2(107, 222),
		"ts_push_1":   Vector2(300, 222),
		"ts_heal_1":   Vector2(554, 222),
		"ts_cooldown": Vector2(747, 222),
		"ts_heal_2":   Vector2(554, 329),
	},
	"wizard": {
		"mt_dmg_1":    Vector2(427, 115),
		"mt_dmg_2":    Vector2(185, 222),
		"mt_radius_1": Vector2(427, 222),
		"mt_cooldown": Vector2(670, 222),
		"mt_radius_2": Vector2(427, 329),
		"mt_multi":    Vector2(310, 400),
	},
}

var viewing_char  : String     = ""
var node_panels   : Dictionary = {}   # node_id -> Panel
var selected_node : String     = ""
var gold_label    : Label      = null
var info_label    : Label      = null
var buy_btn       : Button     = null
var tab_btns      : Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	viewing_char = GameState.selected_character
	_build_background()
	_build_header()
	_build_tabs()
	_build_info_panel()
	_build_tree()

# ── Drawing ───────────────────────────────────────────────────────────────────
func _draw() -> void:
	var tree    : Dictionary = GameState.SKILL_TREES.get(viewing_char, {})
	var pos_map : Dictionary = POSITIONS.get(viewing_char, {})

	for node_id in tree:
		var reqs : Array = tree[node_id].get("requires", [])
		var tp   : Vector2 = pos_map.get(node_id, Vector2.ZERO)

		for req in reqs:
			var fp           : Vector2 = pos_map.get(req, Vector2.ZERO)
			var from_unlocked : bool   = GameState.is_node_unlocked(viewing_char, req)
			var to_unlocked   : bool   = GameState.is_node_unlocked(viewing_char, node_id)

			var col : Color
			if from_unlocked and to_unlocked:
				col = Color(0.28, 0.72, 0.34, 0.95)
			elif from_unlocked:
				col = Color(0.75, 0.60, 0.10, 0.85)
			else:
				col = Color(0.30, 0.25, 0.40, 0.65)

			draw_line(fp, tp, col, 2.5)

# ── Construction ──────────────────────────────────────────────────────────────
func _build_background() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.03, 0.06, 1)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

func _build_header() -> void:
	var hdr := HBoxContainer.new()
	hdr.position = Vector2(8, 6)
	hdr.custom_minimum_size = Vector2(838, 34)
	add_child(hdr)

	var back := Button.new()
	back.text = "← Back"
	back.custom_minimum_size = Vector2(84, 34)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/hub/HubScene.tscn"))
	hdr.add_child(back)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(spacer)

	var title := Label.new()
	title.text = "SKILL TREE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(180, 34)
	title.add_theme_font_size_override("font_size", 14)
	hdr.add_child(title)

	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(spacer2)

	gold_label = Label.new()
	gold_label.custom_minimum_size = Vector2(110, 34)
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	gold_label.add_theme_font_size_override("font_size", 13)
	hdr.add_child(gold_label)
	_refresh_gold()

func _build_tabs() -> void:
	var tabs := HBoxContainer.new()
	tabs.position = Vector2(8, 44)
	tabs.custom_minimum_size = Vector2(838, 32)
	tabs.add_theme_constant_override("separation", 6)
	add_child(tabs)

	for char_id : String in ["warrior", "healer", "wizard"]:
		var char_data : Dictionary = GameState.CHARACTERS.get(char_id, {})
		var btn := Button.new()
		btn.text = char_data.get("name", char_id)
		btn.custom_minimum_size = Vector2(120, 32)
		btn.toggle_mode = true
		btn.button_pressed = (char_id == viewing_char)
		var locked : bool = not (char_id in GameState.unlocked_characters)
		if locked:
			btn.modulate = Color(0.5, 0.5, 0.5, 0.7)
		tab_btns[char_id] = btn
		var cid := char_id   # capture for closure
		btn.pressed.connect(func(): _switch_char(cid))
		tabs.add_child(btn)

func _build_info_panel() -> void:
	var panel := Panel.new()
	panel.position = Vector2(0, 432)
	panel.size = Vector2(854, 48)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.05, 0.10, 0.97)
	style.border_width_top = 1
	style.border_color = Color(0.30, 0.24, 0.40, 0.8)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	info_label = Label.new()
	info_label.position = Vector2(8, 4)
	info_label.size = Vector2(690, 40)
	info_label.add_theme_font_size_override("font_size", 11)
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	panel.add_child(info_label)

	buy_btn = Button.new()
	buy_btn.position = Vector2(706, 7)
	buy_btn.size = Vector2(136, 34)
	buy_btn.text = "Buy"
	buy_btn.visible = false
	buy_btn.pressed.connect(_on_buy_pressed)
	panel.add_child(buy_btn)

	_update_info()

# ── Tree building ─────────────────────────────────────────────────────────────
func _build_tree() -> void:
	var tree    : Dictionary = GameState.SKILL_TREES.get(viewing_char, {})
	var pos_map : Dictionary = POSITIONS.get(viewing_char, {})

	for node_id : String in tree:
		var data   : Dictionary = tree[node_id]
		var center : Vector2    = pos_map.get(node_id, Vector2.ZERO)
		if center == Vector2.ZERO:
			continue
		_create_node_panel(node_id, data, center)

func _create_node_panel(node_id : String, data : Dictionary, center : Vector2) -> void:
	var unlocked : bool = GameState.is_node_unlocked(viewing_char, node_id)
	var can_buy  : bool = _can_buy(node_id, data)

	var panel := Panel.new()
	panel.size     = Vector2(NODE_W, NODE_H)
	panel.position = center - Vector2(NODE_W * 0.5, NODE_H * 0.5)

	var style := StyleBoxFlat.new()
	style.corner_radius_top_left     = 5
	style.corner_radius_top_right    = 5
	style.corner_radius_bottom_left  = 5
	style.corner_radius_bottom_right = 5
	style.border_width_left   = 1
	style.border_width_right  = 1
	style.border_width_top    = 1
	style.border_width_bottom = 1

	if unlocked:
		style.bg_color     = Color(0.11, 0.36, 0.13, 1)
		style.border_color = Color(0.28, 0.78, 0.34, 1)
	elif can_buy:
		style.bg_color     = Color(0.34, 0.27, 0.05, 1)
		style.border_color = Color(0.82, 0.63, 0.10, 1)
	else:
		style.bg_color     = Color(0.09, 0.07, 0.13, 1)
		style.border_color = Color(0.26, 0.22, 0.34, 1)

	panel.add_theme_stylebox_override("panel", style)

	var name_lbl := Label.new()
	name_lbl.position = Vector2(4, 3)
	name_lbl.size = Vector2(NODE_W - 8, 22)
	name_lbl.text = data.get("name", node_id)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 11)
	panel.add_child(name_lbl)

	var sub_lbl := Label.new()
	sub_lbl.position = Vector2(4, 25)
	sub_lbl.size = Vector2(NODE_W - 8, 18)
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_size_override("font_size", 10)
	if unlocked:
		sub_lbl.text    = "✓ Unlocked"
		sub_lbl.modulate = Color(0.65, 1.0, 0.68)
	else:
		sub_lbl.text    = "💰 %d" % data.get("cost", 0)
		sub_lbl.modulate = Color(1.0, 0.85, 0.30)
	panel.add_child(sub_lbl)

	# Invisible touch button on top
	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn.flat = true
	btn.add_theme_color_override("font_color", Color.TRANSPARENT)
	btn.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	btn.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
	btn.add_theme_stylebox_override("normal",   StyleBoxEmpty.new())
	btn.add_theme_stylebox_override("hover",    StyleBoxEmpty.new())
	btn.add_theme_stylebox_override("pressed",  StyleBoxEmpty.new())
	btn.add_theme_stylebox_override("focus",    StyleBoxEmpty.new())
	var nid := node_id   # capture
	var dat := data
	btn.pressed.connect(func(): _on_node_pressed(nid, dat))
	panel.add_child(btn)

	add_child(panel)
	node_panels[node_id] = panel

# ── Logic ─────────────────────────────────────────────────────────────────────
func _can_buy(node_id : String, data : Dictionary) -> bool:
	if GameState.is_node_unlocked(viewing_char, node_id):
		return false
	for req in data.get("requires", []):
		if not GameState.is_node_unlocked(viewing_char, req):
			return false
	return GameState.gold >= data.get("cost", 999)

func _switch_char(char_id : String) -> void:
	viewing_char = char_id
	for cid in tab_btns:
		tab_btns[cid].button_pressed = (cid == char_id)
	for p in node_panels.values():
		p.queue_free()
	node_panels.clear()
	selected_node = ""
	_build_tree()
	queue_redraw()
	_update_info()

func _on_node_pressed(node_id : String, data : Dictionary) -> void:
	selected_node = node_id
	_update_info()

func _on_buy_pressed() -> void:
	if selected_node.is_empty():
		return
	if GameState.unlock_skill_node(viewing_char, selected_node):
		_refresh_gold()
		for p in node_panels.values():
			p.queue_free()
		node_panels.clear()
		_build_tree()
		queue_redraw()
	_update_info()

func _refresh_gold() -> void:
	if gold_label:
		gold_label.text = "💰 %d gold" % GameState.gold

func _update_info() -> void:
	if info_label == null:
		return
	if selected_node.is_empty():
		info_label.text = "Tap a node to see details."
		if buy_btn:
			buy_btn.visible = false
		return

	var tree     : Dictionary = GameState.SKILL_TREES.get(viewing_char, {})
	var data     : Dictionary = tree.get(selected_node, {})
	var name     : String     = data.get("name", selected_node)
	var desc     : String     = data.get("desc", "")
	var cost     : int        = data.get("cost", 0)
	var unlocked : bool       = GameState.is_node_unlocked(viewing_char, selected_node)
	var can_buy  : bool       = _can_buy(selected_node, data)

	var status : String
	if unlocked:
		status = "Already unlocked."
	elif can_buy:
		status = "Cost: %d gold" % cost
	else:
		var reqs : Array = data.get("requires", [])
		var missing : Array = []
		for req in reqs:
			if not GameState.is_node_unlocked(viewing_char, req):
				missing.append(tree.get(req, {}).get("name", req))
		if missing.size() > 0:
			status = "Requires: " + ", ".join(missing)
		else:
			status = "Need %d gold (have %d)" % [cost, GameState.gold]

	info_label.text = "%s  —  %s    %s" % [name, desc, status]

	if buy_btn:
		buy_btn.visible = can_buy
