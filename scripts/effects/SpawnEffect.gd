extends Node2D
# Purple lightning bolt spawn effect.
# Usage:
#   var e = SpawnEffect.new()
#   parent.add_child(e)
#   e.global_position = world_pos
#   e.start(callback)

func start(callback : Callable) -> void:
	_build()
	_run(callback)

func _build() -> void:
	# Outer glow column
	var glow := ColorRect.new()
	glow.color    = Color(0.55, 0.0, 0.95, 0.22)
	glow.size     = Vector2(22, 68)
	glow.position = Vector2(-11, -68)
	add_child(glow)

	# Main vertical bolt
	var bolt := ColorRect.new()
	bolt.color    = Color(0.88, 0.18, 1.0, 1.0)
	bolt.size     = Vector2(5, 58)
	bolt.position = Vector2(-2, -58)
	add_child(bolt)

	# Left branch
	var bl := Node2D.new()
	bl.position = Vector2(-2, -44)
	bl.rotation  = deg_to_rad(-42)
	var bl_r := ColorRect.new()
	bl_r.color = Color(0.88, 0.18, 1.0, 0.85)
	bl_r.size  = Vector2(15, 3)
	bl.add_child(bl_r)
	add_child(bl)

	# Right branch
	var br := Node2D.new()
	br.position = Vector2(3, -27)
	br.rotation  = deg_to_rad(38)
	var br_r := ColorRect.new()
	br_r.color = Color(0.88, 0.18, 1.0, 0.85)
	br_r.size  = Vector2(17, 3)
	br.add_child(br_r)
	add_child(br)

	# Ground splash
	var ground := ColorRect.new()
	ground.color    = Color(0.70, 0.0, 1.0, 0.30)
	ground.size     = Vector2(38, 9)
	ground.position = Vector2(-19, -9)
	add_child(ground)

func _run(callback : Callable) -> void:
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.15, 0.07)
	t.tween_property(self, "modulate:a", 1.00, 0.05)
	t.tween_property(self, "modulate:a", 0.25, 0.07)
	t.tween_property(self, "modulate:a", 1.00, 0.04)
	t.tween_property(self, "modulate:a", 0.45, 0.06)
	t.tween_property(self, "modulate:a", 1.00, 0.04)
	t.tween_interval(0.08)
	t.tween_property(self, "modulate:a", 0.0, 0.20)
	t.tween_callback(func():
		if callback.is_valid():
			callback.call()
		queue_free()
	)
