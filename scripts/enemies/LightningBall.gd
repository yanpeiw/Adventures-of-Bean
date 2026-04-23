extends Node2D

var direction      : Vector2 = Vector2.RIGHT
var speed          : float   = 55.0
var damage         : int     = 3
var fuse_time      : float   = 2.0
var elapsed        : float   = 0.0
var proximity_held : float   = 0.0
var exploded       : bool    = false

const PROXIMITY_RADIUS  : float = 52.0
const TRIGGER_HOLD_TIME : float = 1.0
const EXPLOSION_RADIUS  : float = 90.0

func _ready() -> void:
	z_index = 7

func _draw() -> void:
	var remaining : float = maxf(fuse_time - elapsed, 0.0)
	var danger    : float = 1.0 - clampf(remaining / fuse_time, 0.0, 1.0)

	# Pulsing outer arc / lightning ring
	var pulse : float = sin(Time.get_ticks_msec() * 0.025 + danger * 8.0) * 3.0
	draw_rect(Rect2(-16.0 - pulse, -16.0 - pulse, 32.0 + pulse * 2, 32.0 + pulse * 2),
		Color(1.0, 0.65 - danger * 0.3, 0.05, 0.30 + danger * 0.30))
	# Core ball
	draw_rect(Rect2(-10.0, -10.0, 20.0, 20.0),
		Color(1.0, 0.55 + danger * 0.25, 0.05, 1.0))
	# Inner bright spot
	draw_rect(Rect2(-4.0, -4.0, 8.0, 8.0), Color(1.0, 1.0, 0.60, 1.0))
	# Lightning sparks (small offset rects)
	draw_rect(Rect2(-14.0, -2.0,  4.0, 4.0), Color(1.0, 0.90, 0.20, 0.75))
	draw_rect(Rect2( 10.0, -3.0,  4.0, 4.0), Color(1.0, 0.90, 0.20, 0.75))
	draw_rect(Rect2( -2.0, -14.0, 4.0, 4.0), Color(1.0, 0.90, 0.20, 0.75))
	draw_rect(Rect2( -3.0,  10.0, 4.0, 4.0), Color(1.0, 0.90, 0.20, 0.75))

	# Countdown text above
	var font  : Font  = ThemeDB.fallback_font
	var label : String = "%.1f" % remaining
	var lpos  : Vector2 = Vector2(-10.0, -22.0)
	draw_string(font, lpos + Vector2(1, 1), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11,
		Color(0.0, 0.0, 0.0, 0.70))
	draw_string(font, lpos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11,
		Color(1.0, 0.92, 0.20, 1.0))

func _process(delta : float) -> void:
	if exploded:
		return
	queue_redraw()

	elapsed += delta
	# Move toward initial direction (slows to zero quickly)
	var travel_frac : float = clampf(1.0 - elapsed * 0.6, 0.0, 1.0)
	global_position += direction * speed * travel_frac * delta

	# Proximity check — player standing close triggers early detonation
	var player_close : bool = false
	for node in get_tree().get_nodes_in_group("player"):
		if global_position.distance_to(node.global_position) < PROXIMITY_RADIUS:
			player_close = true
			break
	if player_close:
		proximity_held += delta
	else:
		proximity_held = maxf(proximity_held - delta * 2.0, 0.0)

	if elapsed >= fuse_time or proximity_held >= TRIGGER_HOLD_TIME:
		_explode()

func _explode() -> void:
	if exploded:
		return
	exploded = true
	set_process(false)

	for node in get_tree().get_nodes_in_group("player"):
		if global_position.distance_to(node.global_position) < EXPLOSION_RADIUS:
			GameState.take_damage(damage)

	# Flash expand then fade
	var t := create_tween()
	t.tween_property(self, "scale",      Vector2(4.5, 4.5), 0.10)
	t.tween_property(self, "modulate:a", 0.0,               0.18)
	t.tween_callback(queue_free)
