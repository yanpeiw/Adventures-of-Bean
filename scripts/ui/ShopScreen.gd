extends Control

# Weapon order: cheapest first
const WEAPON_ORDER := [
	"rusty_sword", "cracked_shortsword", "sage_wand", "copper_blade",
	"silver_sword", "oaken_maul", "iron_sword", "knights_sword",
	"steel_longsword", "vine_bow", "spark_fork", "crystal_staff",
	"runic_hatchet", "knights_blade", "war_axe", "silver_edge",
	"enchanted_sword", "druids_staff", "grimoire_mace", "verdant_staff",
	"serpent_staff", "crimson_fang", "azure_bow", "venom_fang",
	"frostfang_hook", "rose_saber", "shadowblade", "moonreaver",
	"regal_scepter", "razorclaw", "frost_edge", "soul_reaver",
	"phantom_saber", "emberblade", "void_edge", "doomcleaver",
	"celestial_blade", "venom_serpent", "star_marrow_blade", "tri_blade",
]

const TIER_BG_COLORS := {
	"common":    Color(0.165, 0.133, 0.208, 1.0),  # #2a2235
	"uncommon":  Color(0.102, 0.165, 0.102, 1.0),  # #1a2a1a
	"rare":      Color(0.102, 0.102, 0.227, 1.0),  # #1a1a3a
	"epic":      Color(0.165, 0.102, 0.227, 1.0),  # #2a1a3a
	"legendary": Color(0.165, 0.102, 0.039, 1.0),  # #2a1a0a
}

const TIER_BORDER_COLORS := {
	"common":    Color(0.4,  0.25, 0.55, 1.0),   # dim purple
	"uncommon":  Color(0.25, 0.5,  0.25, 1.0),   # dim green
	"rare":      Color(0.25, 0.35, 0.65, 1.0),   # dim blue
	"epic":      Color(0.75, 0.25, 1.0,  1.0),   # bright purple
	"legendary": Color(1.0,  0.78, 0.1,  1.0),   # gold
}

var _gold_label: Label
var _list_container: VBoxContainer


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# --- Background ---
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.03, 0.06, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# --- Root VBox ---
	var root_vbox := VBoxContainer.new()
	root_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_vbox.add_theme_constant_override("separation", 0)
	add_child(root_vbox)

	# --- Header ---
	var header := _build_header()
	root_vbox.add_child(header)

	# --- Scroll area ---
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_vbox.add_child(scroll)

	_list_container = VBoxContainer.new()
	_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_container.add_theme_constant_override("separation", 6)
	scroll.add_child(_list_container)

	_populate_list()


func _build_header() -> Control:
	var header := ColorRect.new()
	header.color = Color(0.08, 0.06, 0.12, 1.0)
	header.custom_minimum_size = Vector2(0, 56)

	# Back button
	var back_btn := Button.new()
	back_btn.text = "← Back"
	back_btn.add_theme_font_size_override("font_size", 11)
	back_btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	back_btn.position = Vector2(8, 14)
	back_btn.size = Vector2(72, 28)
	back_btn.pressed.connect(_on_back_pressed)
	header.add_child(back_btn)

	# Title
	var title := Label.new()
	title.text = "⚔ MERCHANT'S WARES"
	title.add_theme_font_size_override("font_size", 14)
	title.modulate = Color(1.0, 0.85, 0.4, 1.0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	header.add_child(title)

	# Gold label
	_gold_label = Label.new()
	_gold_label.add_theme_font_size_override("font_size", 11)
	_gold_label.modulate = Color(1.0, 0.85, 0.2, 1.0)
	_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_gold_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_gold_label.position = Vector2(-110, 14)
	_gold_label.size = Vector2(102, 28)
	_refresh_gold_label()
	header.add_child(_gold_label)

	return header


func _refresh_gold_label() -> void:
	if _gold_label:
		_gold_label.text = "💰 %d" % GameState.gold


func _populate_list() -> void:
	# Clear existing cards
	for child in _list_container.get_children():
		child.queue_free()

	for weapon_id in WEAPON_ORDER:
		if not weapon_id in GameState.WEAPONS:
			continue
		var weapon: Dictionary = GameState.WEAPONS[weapon_id]
		var card := _build_weapon_card(weapon_id, weapon)
		_list_container.add_child(card)


func _build_weapon_card(weapon_id: String, weapon: Dictionary) -> PanelContainer:
	var tier: String = weapon.get("tier", "common")
	var bg_color: Color = TIER_BG_COLORS.get(tier, TIER_BG_COLORS["common"])
	var border_color: Color = TIER_BORDER_COLORS.get(tier, TIER_BORDER_COLORS["common"])

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.content_margin_left   = 10
	style.content_margin_right  = 10
	style.content_margin_top    = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)

	# HBox: [sprite] | info | action
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	panel.add_child(hbox)

	# --- Weapon sprite ---
	var sprite_path : String = weapon.get("sprite", "")
	if sprite_path != "" and ResourceLoader.exists(sprite_path):
		var tex_rect := TextureRect.new()
		tex_rect.texture = load(sprite_path)
		tex_rect.custom_minimum_size = Vector2(48, 48)
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		hbox.add_child(tex_rect)

	# --- Info VBox ---
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(info_vbox)

	# Weapon name
	var name_label := Label.new()
	name_label.text = weapon.get("name", weapon_id)
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	info_vbox.add_child(name_label)

	# Stats line
	var damage = weapon.get("damage", 0)
	var range_val = weapon.get("range", 0.0)
	var arc_val = weapon.get("slash_arc", 0.0)
	var stats_label := Label.new()
	stats_label.text = "DMG %s  RNG %.0f  ARC %.0f°" % [str(damage), range_val, arc_val]
	stats_label.add_theme_font_size_override("font_size", 8)
	stats_label.modulate = Color(0.8, 0.85, 0.9, 1.0)
	info_vbox.add_child(stats_label)

	# Description
	var desc_label := Label.new()
	desc_label.text = weapon.get("desc", "")
	desc_label.add_theme_font_size_override("font_size", 7)
	desc_label.modulate = Color(0.7, 0.65, 0.75, 1.0)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(desc_label)

	# --- Action VBox ---
	var action_vbox := VBoxContainer.new()
	action_vbox.custom_minimum_size = Vector2(80, 0)
	action_vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	action_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	action_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(action_vbox)

	var is_unlocked: bool = weapon_id in GameState.unlocked_weapons
	var is_equipped: bool = (
		GameState.current_weapon is Dictionary
		and GameState.current_weapon.get("id", "") == weapon_id
	)

	if is_unlocked:
		# Owned label
		var owned_label := Label.new()
		owned_label.text = "✓ Owned"
		owned_label.add_theme_font_size_override("font_size", 8)
		owned_label.modulate = Color(0.4, 0.9, 0.4, 1.0)
		owned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		action_vbox.add_child(owned_label)

		# Equip / Equipped button
		var equip_btn := Button.new()
		if is_equipped:
			equip_btn.text = "Equipped"
			equip_btn.disabled = true
			equip_btn.modulate = Color(0.7, 0.7, 0.7, 1.0)
		else:
			equip_btn.text = "Equip"
			equip_btn.pressed.connect(_on_equip_pressed.bind(weapon_id))
		equip_btn.add_theme_font_size_override("font_size", 9)
		equip_btn.custom_minimum_size = Vector2(76, 26)
		action_vbox.add_child(equip_btn)
	else:
		var cost: int = weapon.get("cost", 0)
		var can_afford: bool = GameState.gold >= cost

		# Cost label
		var cost_label := Label.new()
		cost_label.text = "💰 %d" % cost
		cost_label.add_theme_font_size_override("font_size", 8)
		cost_label.modulate = Color(1.0, 0.85, 0.2, 1.0) if can_afford else Color(0.55, 0.5, 0.35, 1.0)
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		action_vbox.add_child(cost_label)

		# Buy button
		var buy_btn := Button.new()
		buy_btn.text = "Buy"
		buy_btn.add_theme_font_size_override("font_size", 9)
		buy_btn.custom_minimum_size = Vector2(76, 26)
		if not can_afford:
			buy_btn.disabled = true
			buy_btn.modulate = Color(0.5, 0.5, 0.5, 0.6)
		else:
			buy_btn.pressed.connect(_on_buy_pressed.bind(weapon_id, cost))
		action_vbox.add_child(buy_btn)

	return panel


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/hub/HubScene.tscn")


func _on_equip_pressed(weapon_id: String) -> void:
	GameState.equip_weapon(weapon_id)
	GameState.save()
	_populate_list()


func _on_buy_pressed(weapon_id: String, cost: int) -> void:
	if GameState.gold < cost:
		return
	GameState.spend_gold(cost)
	if not weapon_id in GameState.unlocked_weapons:
		GameState.unlocked_weapons.append(weapon_id)
	GameState.equip_weapon(weapon_id)
	GameState.save()
	_refresh_gold_label()
	_populate_list()
