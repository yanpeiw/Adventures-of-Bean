extends Node2D
# Draws soft inner-shadow gradients along every wall edge, giving the room walls height.

var room_w : int = 1280
var room_h : int = 720
var wall_t : int = 16

func _ready() -> void:
	z_index   = 2   # above tilemap (1), below characters (3)
	y_sort_enabled = false

func _draw() -> void:
	var depth : int = 36   # how far the shadow bleeds into the room
	var step  : int = 2    # pixels per strip

	for i in range(0, depth, step):
		var t : float = float(i) / depth
		# Non-linear falloff — dark near wall, rapid fade outward
		var alpha : float = 0.52 * pow(1.0 - t, 2.2)
		var c     : Color = Color(0.0, 0.0, 0.0, alpha)
		var y_top    : int = wall_t + i
		var y_bot    : int = room_h - wall_t - i - step
		var x_left   : int = wall_t + i
		var x_right  : int = room_w - wall_t - i - step

		# Top wall shadow bleeds downward
		draw_rect(Rect2(0, y_top, room_w, step), c)
		# Bottom wall shadow bleeds upward
		draw_rect(Rect2(0, y_bot, room_w, step), c)
		# Left wall shadow bleeds rightward
		draw_rect(Rect2(x_left, 0, step, room_h), c)
		# Right wall shadow bleeds leftward
		draw_rect(Rect2(x_right, 0, step, room_h), c)
