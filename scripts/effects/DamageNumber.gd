extends Node2D
# Floating damage number that rises and fades above a hit enemy.

func setup(amount : int) -> void:
	z_index = 20   # always renders on top of everything in world space

	var lbl := Label.new()
	lbl.text = str(amount)

	# Colour: white for small hits, orange for medium, red for big
	var col : Color
	if amount >= 8:
		col = Color(1.0, 0.22, 0.10, 1.0)   # red — big hit
	elif amount >= 4:
		col = Color(1.0, 0.65, 0.10, 1.0)   # orange — medium
	else:
		col = Color(1.0, 0.95, 0.35, 1.0)   # yellow — small

	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	lbl.position = Vector2(-10.0, 0.0)
	add_child(lbl)

	# Rise upward
	var rise := create_tween()
	rise.tween_property(self, "position:y", position.y - 52.0, 0.70)

	# Fade out and free after a short hold
	var fade := create_tween()
	fade.tween_interval(0.28)
	fade.tween_property(self, "modulate:a", 0.0, 0.42)
	fade.tween_callback(queue_free)
