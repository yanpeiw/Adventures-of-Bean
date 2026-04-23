extends Node2D

var direction : Vector2 = Vector2.RIGHT
var speed     : float   = 175.0
var damage    : int     = 1
var max_range : float   = 260.0
var traveled  : float   = 0.0
var _wobble   : float   = 0.0

func _ready() -> void:
	z_index = 6

func _draw() -> void:
	var w := _wobble
	# Lumpy spore body
	draw_rect(Rect2(-8.0 - w, -7.0,       16.0 + w * 2, 14.0),       Color(0.22, 0.68, 0.14, 1.0))
	draw_rect(Rect2(-6.0,     -9.0 - w,   12.0,          14.0 + w),   Color(0.28, 0.78, 0.18, 1.0))
	# Nubs / bumps
	draw_rect(Rect2(-10.0, -3.0, 4.0, 6.0), Color(0.18, 0.58, 0.10, 1.0))
	draw_rect(Rect2(  6.0, -4.0, 4.0, 5.0), Color(0.18, 0.58, 0.10, 1.0))
	draw_rect(Rect2(-2.0, -11.0, 4.0, 4.0), Color(0.18, 0.58, 0.10, 1.0))
	# Spore dots
	draw_rect(Rect2(-3.0, -3.0, 2.0, 2.0), Color(0.60, 0.92, 0.30, 0.80))
	draw_rect(Rect2( 1.0,  2.0, 2.0, 2.0), Color(0.60, 0.92, 0.30, 0.80))

func _process(delta : float) -> void:
	_wobble = sin(Time.get_ticks_msec() * 0.014) * 1.5
	queue_redraw()
	var move := direction * speed * delta
	global_position += move
	traveled        += move.length()

	for node in get_tree().get_nodes_in_group("player"):
		if global_position.distance_to(node.global_position) < 20.0:
			GameState.take_damage(damage)
			queue_free()
			return

	if traveled >= max_range:
		queue_free()
