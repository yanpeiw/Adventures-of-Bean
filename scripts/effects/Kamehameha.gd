extends Node2D

var direction    : Vector2 = Vector2.RIGHT
var damage       : int     = 10
var beam_width   : float   = 34.0
var max_length   : float   = 720.0
var grow_speed   : float   = 500.0
var current_len  : float   = 0.0
var hit_enemies  : Array   = []
var beam_color   : Color   = Color(1.0, 0.55, 0.05, 0.92)
var follow_node  : Node2D  = null

var held          : bool  = true
var _total_time   : float = 0.0
var _max_duration : float = 6.0  # safety cap

func _ready() -> void:
	z_index  = 10
	rotation = direction.angle()
	_charge_flash()

func _draw() -> void:
	if current_len <= 0.0:
		return
	var hw   : float = beam_width * 0.5
	var glow : Color = Color(beam_color.r, beam_color.g, beam_color.b, 0.22)
	var mid  : Color = beam_color.lightened(0.55)
	draw_rect(Rect2(0.0, -(hw + 14.0), current_len, beam_width + 28.0), glow)
	draw_rect(Rect2(0.0, -hw, current_len, beam_width), beam_color)
	draw_rect(Rect2(0.0, -beam_width * 0.19, current_len, beam_width * 0.38), mid)
	draw_rect(Rect2(current_len - 8.0, -hw - 4.0, 16.0, beam_width + 8.0),
		Color(1.0, 1.0, 0.85, 0.90))

func _charge_flash() -> void:
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0,  0.04)
	t.tween_property(self, "modulate:a", 1.0,  0.04)
	t.tween_property(self, "modulate:a", 0.15, 0.04)
	t.tween_property(self, "modulate:a", 1.0,  0.05)

func _process(delta : float) -> void:
	# Origin follows caster
	if follow_node and is_instance_valid(follow_node):
		global_position = follow_node.global_position

	# Track nearest enemy
	var best_dist : float   = INF
	var best_dir  : Vector2 = direction
	for e in get_tree().get_nodes_in_group("enemies"):
		var d : float = global_position.distance_to(e.global_position)
		if d < best_dist:
			best_dist = d
			best_dir  = (e.global_position - global_position).normalized()
	direction = direction.lerp(best_dir, 4.0 * delta).normalized()
	rotation  = direction.angle()

	# Grow until max, then sustain while held
	current_len  = minf(current_len + grow_speed * delta, max_length)
	_total_time += delta
	if not held or _total_time >= _max_duration:
		set_process(false)
		_fade_out()
		return

	queue_redraw()

	# Damage enemies inside beam
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy in hit_enemies:
			continue
		var lp : Vector2 = to_local(enemy.global_position)
		if lp.x >= 0.0 and lp.x <= current_len \
		   and absf(lp.y) <= beam_width * 0.5 + 20.0:
			hit_enemies.append(enemy)
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)

func _fade_out() -> void:
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.40)
	t.tween_callback(queue_free)
