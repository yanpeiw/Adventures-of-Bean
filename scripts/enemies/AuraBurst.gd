extends Node2D

var direction : Vector2 = Vector2.RIGHT
var speed     : float   = 240.0
var damage    : int     = 1
var max_range : float   = 380.0
var traveled  : float   = 0.0
var _pulse    : float   = 0.0

func _ready() -> void:
	z_index = 6

func _draw() -> void:
	var p := _pulse
	# Outer soft glow
	draw_rect(Rect2(-12.0 - p, -12.0 - p, 24.0 + p * 2, 24.0 + p * 2),
		Color(0.85, 0.92, 1.00, 0.22))
	# Core orb
	draw_rect(Rect2(-7.0, -7.0, 14.0, 14.0), Color(0.80, 0.90, 1.00, 0.92))
	# Bright centre
	draw_rect(Rect2(-3.0, -3.0,  6.0,  6.0), Color(1.00, 1.00, 1.00, 1.00))

func _process(delta : float) -> void:
	_pulse = sin(Time.get_ticks_msec() * 0.020) * 2.5
	queue_redraw()
	var move := direction * speed * delta
	global_position += move
	traveled        += move.length()
	rotation         = direction.angle()

	for node in get_tree().get_nodes_in_group("player"):
		if global_position.distance_to(node.global_position) < 20.0:
			GameState.take_damage(damage)
			queue_free()
			return

	if traveled >= max_range:
		queue_free()
