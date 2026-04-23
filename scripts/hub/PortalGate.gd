extends Node2D

var _t : float = 0.0

func _ready() -> void:
	z_index = 2

func _process(delta : float) -> void:
	_t += delta
	queue_redraw()

func _draw() -> void:
	var r : float = 50.0

	# Outer stone ring
	draw_arc(Vector2.ZERO, r + 12.0, 0.0, TAU, 64,
		Color(0.28, 0.22, 0.36, 1.0), 14.0)

	# Rune tick marks on ring
	for i in 8:
		var a : float = i * TAU / 8.0
		var inner : Vector2 = Vector2(cos(a), sin(a)) * (r + 4.0)
		var outer : Vector2 = Vector2(cos(a), sin(a)) * (r + 16.0)
		draw_line(inner, outer, Color(0.72, 0.55, 1.0, 0.8), 2.0)

	# Spinning energy rings
	for i in 3:
		var spd  : float = 0.6 + i * 0.35
		var off  : float = _t * spd + i * TAU / 3.0
		var ring : float = r - i * 10.0
		var arc  : float = TAU * (0.55 + 0.15 * sin(_t + i))
		var col  : Color = Color(
			0.30 + 0.10 * sin(off * 0.8),
			0.10 + 0.08 * cos(off * 0.6),
			0.85 + 0.12 * sin(off * 1.1),
			0.85
		)
		draw_arc(Vector2.ZERO, ring, off, off + arc, 32, col, 4.5)

	# Inner void
	draw_circle(Vector2.ZERO, r - 28.0, Color(0.02, 0.01, 0.10, 1.0))

	# Inner swirl dots
	for i in 5:
		var a    : float   = _t * 1.8 + i * TAU / 5.0
		var dist : float   = (r - 28.0) * 0.6 + 6.0 * sin(_t * 3.0 + i)
		var p    : Vector2 = Vector2(cos(a) * dist, sin(a) * dist)
		var glow : float   = 0.5 + 0.5 * sin(_t * 4.0 + i)
		draw_circle(p, 3.5, Color(0.65, 0.30 + glow * 0.30, 1.0, 0.75 + glow * 0.25))

	# Outer glow pulse
	var pulse : float = 0.18 + 0.06 * sin(_t * 2.3)
	draw_arc(Vector2.ZERO, r + 22.0, 0.0, TAU, 64,
		Color(0.55, 0.20, 1.0, pulse), 8.0)
