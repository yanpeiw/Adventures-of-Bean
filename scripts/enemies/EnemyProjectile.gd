extends Node2D

var direction  : Vector2 = Vector2.RIGHT
var speed      : float   = 190.0
var damage     : int     = 1
var max_range  : float   = 300.0
var proj_color : Color   = Color(1.0, 0.3, 0.3, 1.0)
var traveled   : float   = 0.0

func _ready() -> void:
	z_index = 6

func _draw() -> void:
	draw_rect(Rect2(-6.0, -6.0, 12.0, 12.0), proj_color)
	draw_rect(Rect2(-3.0, -3.0,  6.0,  6.0), proj_color.lightened(0.45))

func _process(delta : float) -> void:
	queue_redraw()
	var move := direction * speed * delta
	global_position += move
	traveled        += move.length()
	rotation         = direction.angle()

	for node in get_tree().get_nodes_in_group("player"):
		if global_position.distance_to(node.global_position) < 22.0:
			GameState.take_damage(damage)
			queue_free()
			return

	if traveled >= max_range:
		queue_free()
