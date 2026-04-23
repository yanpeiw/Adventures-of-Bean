extends Control
## Branching floor mini-map drawn at top-right.
## Reads the floor graph and visited rooms directly from GameState.

const BOX_W  : float = 14.0
const BOX_H  : float = 11.0
const CELL_X : float = 24.0   # pixels per column step
const CELL_Y : float = 18.0   # pixels per row step

func _draw() -> void:
	var graph   : Dictionary = GameState.get_floor_graph()
	var layout  : Dictionary = GameState.get_floor_map_layout()
	var current : int        = GameState.current_room
	var visited : Array      = GameState.visited_rooms

	# Draw edges underneath boxes
	for from_id in graph:
		var fp : Vector2 = _box_center(layout.get(from_id, Vector2i.ZERO))
		for to_id in graph[from_id]:
			var tp : Vector2 = _box_center(layout.get(to_id, Vector2i.ZERO))
			draw_line(fp, tp, Color(0.45, 0.45, 0.52, 0.85), 1.5)

	# Draw room boxes
	for room_id in layout:
		var pos : Vector2i = layout[room_id]
		var rx  : float    = pos.x * CELL_X
		var ry  : float    = pos.y * CELL_Y

		var fill : Color
		if room_id == current:
			fill = Color(0.95, 0.80, 0.15, 1.0)    # gold — current
		elif room_id in visited:
			fill = Color(0.28, 0.28, 0.33, 1.0)    # grey — visited
		else:
			fill = Color(0.07, 0.07, 0.11, 1.0)    # black — unseen

		var box := Rect2(rx, ry, BOX_W, BOX_H)
		draw_rect(box, fill)
		draw_rect(box, Color(0.52, 0.52, 0.62, 0.85), false, 1.2)

		# Exit room: red inner tint
		if graph.get(room_id, []).is_empty():
			draw_rect(
				Rect2(rx + 2.5, ry + 2.0, BOX_W - 5.0, BOX_H - 4.0),
				Color(0.90, 0.18, 0.08, 0.45)
			)

func _box_center(pos : Vector2i) -> Vector2:
	return Vector2(pos.x * CELL_X + BOX_W * 0.5,
	               pos.y * CELL_Y + BOX_H * 0.5)
