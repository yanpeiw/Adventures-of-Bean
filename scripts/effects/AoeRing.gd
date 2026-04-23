extends Node2D

var radius : float = 120.0
var color  : Color = Color(1.0, 0.8, 0.2, 1.0)

func _ready() -> void:
	z_index = 8
	queue_redraw()
	var t := create_tween()
	t.tween_property(self, "scale",      Vector2(1.4, 1.4), 0.30)
	t.parallel().tween_property(self, "modulate:a", 0.0,     0.30)
	t.tween_callback(queue_free)

func _draw() -> void:
	draw_arc(Vector2.ZERO, radius,       0.0, TAU, 64, color,               5.0)
	draw_arc(Vector2.ZERO, radius * 0.6, 0.0, TAU, 64, color.lightened(0.4), 3.0)
