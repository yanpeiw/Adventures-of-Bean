extends Node2D

func _draw() -> void:
	var blade  := Color(0.60, 0.62, 0.58, 1.0)
	var rust   := Color(0.55, 0.30, 0.10, 1.0)
	var handle := Color(0.28, 0.18, 0.10, 1.0)
	var guard  := rust.darkened(0.20)
	# Pommel
	draw_rect(Rect2(-5.0, -2.5, 4.0, 5.0), guard)
	# Handle
	draw_rect(Rect2(-1.0, -1.5, 7.0, 3.0), handle)
	# Crossguard
	draw_rect(Rect2(5.0, -5.0, 3.0, 10.0), guard)
	# Blade
	draw_rect(Rect2(7.0, -1.5, 14.0, 3.0), blade)
	# Rust patches on blade
	draw_rect(Rect2(9.0, -1.5, 3.0, 2.0), rust)
	draw_rect(Rect2(15.0, 0.5, 2.0, 1.0), rust)
	# Tip
	draw_rect(Rect2(20.0, -1.0, 4.0, 2.0), blade)
