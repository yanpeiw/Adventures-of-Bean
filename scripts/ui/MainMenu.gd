extends Control

@onready var play_btn    : Button = $CenterContainer/VBox/PlayButton
@onready var options_btn : Button = $CenterContainer/VBox/OptionsButton
@onready var quit_btn    : Button = $CenterContainer/VBox/QuitButton

func _ready() -> void:
	GameState.load_save()
	play_btn.pressed.connect(_on_play)
	options_btn.pressed.connect(_on_options)
	quit_btn.pressed.connect(_on_quit)
	_style_buttons()

func _style_buttons() -> void:
	for btn : Button in [play_btn, options_btn, quit_btn]:
		var s := StyleBoxFlat.new()
		s.bg_color = Color(0.10, 0.06, 0.18, 0.92)
		s.border_color = Color(0.55, 0.30, 0.82, 1.0)
		s.border_width_left   = 2
		s.border_width_right  = 2
		s.border_width_top    = 2
		s.border_width_bottom = 2
		s.corner_radius_top_left     = 8
		s.corner_radius_top_right    = 8
		s.corner_radius_bottom_left  = 8
		s.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("normal", s)
		btn.add_theme_color_override("font_color", Color(0.92, 0.80, 0.32))
		btn.add_theme_font_size_override("font_size", 18)

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/hub/HubScene.tscn")

func _on_options() -> void:
	_show_options_overlay()

func _show_options_overlay() -> void:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.78)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)

	var panel := PanelContainer.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color    = Color(0.08, 0.05, 0.14, 0.96)
	ps.border_color = Color(0.55, 0.35, 0.85)
	ps.border_width_left   = 2; ps.border_width_right  = 2
	ps.border_width_top    = 2; ps.border_width_bottom = 2
	ps.corner_radius_top_left    = 12; ps.corner_radius_top_right    = 12
	ps.corner_radius_bottom_left = 12; ps.corner_radius_bottom_right = 12
	panel.add_theme_stylebox_override("panel", ps)
	panel.anchor_left   = 0.5; panel.anchor_right  = 0.5
	panel.anchor_top    = 0.5; panel.anchor_bottom = 0.5
	panel.offset_left   = -160; panel.offset_right  = 160
	panel.offset_top    = -110; panel.offset_bottom = 110
	overlay.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Options"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.92, 0.80, 0.32))
	vbox.add_child(title)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var note := Label.new()
	note.text = "More options coming soon."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_color_override("font_color", Color(0.70, 0.65, 0.80))
	vbox.add_child(note)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.add_theme_color_override("font_color", Color(0.85, 0.75, 1.0))
	close_btn.pressed.connect(overlay.queue_free)
	vbox.add_child(close_btn)

	add_child(overlay)

func _on_quit() -> void:
	get_tree().quit()
