extends Node2D

# Chibi spritesheet characters.
# Each sheet is a 3-col × 3-row grid of 48×48 frames.
# Frame layout:  0 1 2 / 3 4 5 / 6 7 8
# Walk cycle uses frames 0-7; frame 8 is the loop-back duplicate of frame 0.

const CHAR_SPRITES : Dictionary = {
	"healer": {
		"sheet":       "res://art/characters/healer_walk.png",
		"hframes":     3,
		"vframes":     3,
		"walk_frames": [0, 1, 2, 3, 4, 5, 6, 7],
		"idle_frame":  0,
		"walk_fps":    8.0,
	},
	"warrior": {
		"sheet":       "res://art/characters/warrior_walk.png",
		"hframes":     3,
		"vframes":     2,
		"walk_frames": [0, 1, 2, 3, 4],
		"idle_frame":  0,
		"walk_fps":    8.0,
	},
	"wizard": {
		"sheet":       "res://art/characters/wizard_walk.png",
		"hframes":     3,
		"vframes":     2,
		"walk_frames": [0, 1, 2, 3, 4],
		"idle_frame":  0,
		"walk_fps":    8.0,
	},
}

var _sprite      : Sprite2D = null
var _walking     : bool     = false
var _busy        : bool     = false
var _walk_timer  : float    = 0.0
var _walk_idx    : int      = 0
var _walk_fps    : float    = 8.0
var _walk_frames : Array    = [0, 1, 2, 3, 4, 5, 6, 7]
var _idle_frame  : int      = 0


func setup(char_id : String) -> void:
	for c in get_children():
		c.queue_free()
	var data : Dictionary = CHAR_SPRITES.get(char_id, {})
	if data.is_empty():
		return
	_sprite               = Sprite2D.new()
	_sprite.texture       = load(data["sheet"])
	_sprite.hframes       = data.get("hframes", 3)
	_sprite.vframes       = data.get("vframes", 3)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.centered      = true
	add_child(_sprite)
	_walk_frames = data.get("walk_frames", [0, 1, 2, 3, 4, 5, 6, 7])
	_idle_frame  = data.get("idle_frame",  0)
	_walk_fps    = data.get("walk_fps",    8.0)
	_sprite.frame = _idle_frame
	scale = Vector2(1.5, 1.5)


func is_busy() -> bool:
	return _busy


func set_facing(dir : String) -> void:
	if _sprite:
		_sprite.flip_h = (dir == "east")  # sprites face left by default


func set_walking(val : bool) -> void:
	if _busy:
		return
	_walking = val
	if not val:
		_walk_idx   = 0
		_walk_timer = 0.0
		if _sprite:
			_sprite.frame = _idle_frame


func play_anim(_anim : String, _fps : float, _on_done : Callable = Callable()) -> void:
	pass  # attack/cast animations added per-character later


func start_cast_loop(_fps : float = 8.0) -> void:
	pass


func stop_cast_loop() -> void:
	pass


func _process(delta : float) -> void:
	if _walking and _sprite:
		_walk_timer += delta
		if _walk_timer >= 1.0 / _walk_fps:
			_walk_timer = 0.0
			_walk_idx   = (_walk_idx + 1) % _walk_frames.size()
			_sprite.frame = _walk_frames[_walk_idx]
