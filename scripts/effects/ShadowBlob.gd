extends Node2D

var blob_w : float = 22.0
var blob_h : float = 7.0

func _ready() -> void:
	z_as_relative = true
	z_index       = -1   # renders behind parent character, above tilemap (-10)

func _draw() -> void:
	var steps : int = 40
	var scales : Array = [2.00, 1.40, 1.00]
	var alphas : Array = [0.14, 0.28, 0.48]
	for r in 3:
		var sc : float = scales[r]
		var al : float = alphas[r]
		var pts := PackedVector2Array()
		for i in steps:
			var a : float = (float(i) / steps) * TAU
			pts.append(Vector2(cos(a) * blob_w * sc, sin(a) * blob_h * sc))
		draw_colored_polygon(pts, Color(0.0, 0.0, 0.0, al))
