extends Node2D

var direction : Vector2 = Vector2.RIGHT
var speed     : float   = 130.0
var damage    : int     = 2
var max_range : float   = 280.0
var traveled  : float   = 0.0
var _rot      : float   = 0.0

func _ready() -> void:
	z_index = 6

func _draw() -> void:
	draw_rect(Rect2(-11.0, -11.0, 22.0, 22.0), Color(0.50, 0.42, 0.30, 1.0))
	draw_rect(Rect2(-8.0,  -8.0,  16.0, 16.0), Color(0.42, 0.34, 0.22, 1.0))
	draw_rect(Rect2(-3.0,  -7.0,   5.0,  3.0), Color(0.62, 0.54, 0.40, 1.0))
	draw_rect(Rect2( 2.0,   2.0,   4.0,  3.0), Color(0.32, 0.24, 0.14, 1.0))
	draw_rect(Rect2(-6.0,   3.0,   3.0,  2.0), Color(0.56, 0.48, 0.34, 1.0))

func _process(delta : float) -> void:
	_rot += delta * 5.0
	rotation = _rot
	queue_redraw()
	var move := direction * speed * delta
	global_position += move
	traveled        += move.length()

	for node in get_tree().get_nodes_in_group("player"):
		if global_position.distance_to(node.global_position) < 24.0:
			GameState.take_damage(damage)
			queue_free()
			return

	if traveled >= max_range:
		queue_free()
