extends Node2D

var direction  : Vector2 = Vector2.RIGHT
var speed      : float   = 400.0
var damage     : int     = 5
var max_range  : float   = 320.0

var _traveled  : float   = 0.0
var _hit       : bool    = false

func _ready() -> void:
	z_index  = 15
	rotation = direction.angle()
	queue_redraw()

func _process(delta : float) -> void:
	global_position += direction * speed * delta
	_traveled       += speed * delta
	queue_redraw()

	if not _hit:
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if global_position.distance_to(enemy.global_position) < 28.0:
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)
				_hit = true
				_expire()
				return

	if _traveled >= max_range:
		_expire()

func _expire() -> void:
	set_process(false)
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.12)
	t.tween_callback(queue_free)

func _draw() -> void:
	var outer_r : float = 20.0
	var inner_r : float = 8.0
	var spread  : float = deg_to_rad(145.0)
	var steps   : int   = 24

	# Thick arc: outer edge forward, inner edge reversed — no offset = no self-intersection
	var pts := PackedVector2Array()
	for i in range(steps + 1):
		var a : float = -spread + (float(i) / steps) * (spread * 2.0)
		pts.append(Vector2(cos(a), sin(a)) * outer_r)
	for i in range(steps + 1):
		var a : float = spread - (float(i) / steps) * (spread * 2.0)
		pts.append(Vector2(cos(a), sin(a)) * inner_r)

	draw_colored_polygon(pts, Color(1.0, 1.0, 0.92, 1.0))

	# Bright highlight strip along the outer edge
	var hl := PackedVector2Array()
	var hs : float = spread * 0.85
	for i in range(steps + 1):
		var a : float = -hs + (float(i) / steps) * (hs * 2.0)
		hl.append(Vector2(cos(a), sin(a)) * outer_r)
	for i in range(steps + 1):
		var a : float = hs - (float(i) / steps) * (hs * 2.0)
		hl.append(Vector2(cos(a), sin(a)) * (outer_r - 4.0))
	draw_colored_polygon(hl, Color(1.0, 1.0, 1.0, 0.55))
