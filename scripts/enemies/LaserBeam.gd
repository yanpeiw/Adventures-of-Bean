extends Node2D

var direction : Vector2 = Vector2.RIGHT
var speed     : float   = 340.0
var damage    : int     = 2
var max_range : float   = 700.0
var traveled  : float   = 0.0

func _ready() -> void:
	z_index = 6
	rotation = direction.angle()

func _draw() -> void:
	# Elongated beam pointing along +X (rotation handles direction)
	draw_rect(Rect2(-56.0, -8.0, 112.0, 16.0), Color(1.00, 0.12, 0.35, 0.65))
	draw_rect(Rect2(-54.0, -5.0, 108.0, 10.0), Color(1.00, 0.45, 0.65, 1.00))
	draw_rect(Rect2(-50.0, -2.0, 100.0,  4.0), Color(1.00, 0.88, 0.92, 1.00))

func _process(delta : float) -> void:
	var move := direction * speed * delta
	global_position += move
	traveled        += move.length()

	for node in get_tree().get_nodes_in_group("player"):
		if global_position.distance_to(node.global_position) < 22.0:
			GameState.take_damage(damage)
			queue_free()
			return

	if traveled >= max_range:
		queue_free()
