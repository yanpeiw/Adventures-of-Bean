extends Node2D

var direction : Vector2 = Vector2.RIGHT
var speed     : float   = 210.0
var damage    : int     = 1
var max_range : float   = 320.0
var traveled  : float   = 0.0

func _ready() -> void:
	z_index = 6

func _draw() -> void:
	# Crescent / arc shape — outer ring minus inner arc = dark-water slash
	var outer_r : float = 15.0
	var inner_r : float = 7.0
	var half    : float = deg_to_rad(75.0)
	var steps   : int   = 12
	var pts     := PackedVector2Array()

	for i in (steps + 1):
		var a : float = -half + (float(i) / steps) * half * 2.0
		pts.append(Vector2(cos(a), sin(a)) * outer_r)
	for i in (steps + 1):
		var a : float = half - (float(i) / steps) * half * 2.0
		pts.append(Vector2(cos(a), sin(a)) * inner_r)

	draw_colored_polygon(pts, Color(0.08, 0.20, 0.55, 0.92))

	# Bright water-edge highlight
	var edge := PackedVector2Array()
	for i in (steps + 1):
		var a : float = -half + (float(i) / steps) * half * 2.0
		edge.append(Vector2(cos(a), sin(a)) * (outer_r + 2.0))
	draw_polyline(edge, Color(0.50, 0.80, 1.00, 0.75), 2.5)

	# Trailing drips
	draw_rect(Rect2(-outer_r - 8.0, -2.0,  6.0, 4.0), Color(0.15, 0.35, 0.75, 0.55))
	draw_rect(Rect2(-outer_r - 14.0, -1.0, 3.0, 2.0), Color(0.10, 0.25, 0.60, 0.35))

func _process(delta : float) -> void:
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
