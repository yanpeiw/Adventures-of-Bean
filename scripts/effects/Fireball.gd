extends Node2D

var direction   : Vector2 = Vector2.RIGHT
var speed       : float   = 270.0
var damage      : int     = 3
var max_range   : float   = 400.0
var traveled    : float   = 0.0
var hit_enemies : Array   = []
var proj_color  : Color   = Color(1.0, 0.50, 0.04, 1.0)

var _pulse      : float   = 0.0
var _trail      : Array   = []

func _ready() -> void:
	z_index = 12
	queue_redraw()

func _draw() -> void:
	var p    : float = _pulse
	var glow : Color = Color(proj_color.r, proj_color.g, proj_color.b, 0.30)
	var mid  : Color = proj_color.lightened(0.35)
	var hot  : Color = Color(1.0, 1.0, 0.90, 1.0)

	for i in _trail.size():
		var tp  : Vector2 = to_local(_trail[i])
		var age : float   = 1.0 - float(i + 1) / (_trail.size() + 1)
		var sz  : float   = 10.0 * age
		draw_rect(Rect2(tp.x - sz * 0.5, tp.y - sz * 0.5, sz, sz),
			Color(proj_color.r, proj_color.g, proj_color.b, 0.55 * age))

	draw_rect(Rect2(-20.0 - p, -20.0 - p, 40.0 + p * 2.0, 40.0 + p * 2.0), glow)
	draw_rect(Rect2(-14.0, -14.0, 28.0, 28.0), proj_color)
	draw_rect(Rect2(-7.0,  -7.0,  14.0, 14.0), mid)
	draw_rect(Rect2(-3.0,  -3.0,   6.0,  6.0), hot)

func _process(delta : float) -> void:
	_pulse = sin(Time.get_ticks_msec() * 0.018) * 4.0
	queue_redraw()

	# Store trail position before moving
	_trail.push_front(global_position)
	if _trail.size() > 6:
		_trail.pop_back()

	# Home toward nearest enemy
	var best_dist : float   = INF
	var best_dir  : Vector2 = direction
	for e in get_tree().get_nodes_in_group("enemies"):
		var d : float = global_position.distance_to(e.global_position)
		if d < best_dist:
			best_dist = d
			best_dir  = (e.global_position - global_position).normalized()
	direction = direction.lerp(best_dir, 6.0 * delta).normalized()

	global_position += direction * speed * delta
	traveled        += speed * delta

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy in hit_enemies:
			continue
		if global_position.distance_to(enemy.global_position) < 30.0:
			hit_enemies.append(enemy)
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)
			_explode()
			return

	if traveled >= max_range:
		_fizzle()

func _explode() -> void:
	set_process(false)
	_trail.clear()
	var t := create_tween()
	t.tween_property(self, "scale",      Vector2(4.0, 4.0), 0.10)
	t.tween_property(self, "modulate:a", 0.0,               0.14)
	t.tween_callback(queue_free)

func _fizzle() -> void:
	set_process(false)
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.18)
	t.tween_callback(queue_free)
