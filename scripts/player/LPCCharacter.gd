extends Node2D

# LPC sheet is always 13 cols × 21 rows @ 64×64 px per frame.
# All layers are the same size so frame indices are identical across layers.
const SHEET_COLS : int = 13
const FRAME_H    : int = 64

# Row indices — south-facing (toward camera) rows for top-down feel; flip_h for left/right.
const ROW_CAST  : int = 3   # cast south  — 7 frames
const ROW_WALK  : int = 10  # walk south  — 9 frames
const ROW_SLASH : int = 15  # slash south — 6 frames
const ROW_HURT  : int = 20  # hurt        — 6 frames

const FRAMES_CAST  : int = 7
const FRAMES_WALK  : int = 9
const FRAMES_SLASH : int = 6
const FRAMES_HURT  : int = 6

const CHAR_LAYERS : Dictionary = {
	"wizard": [
		"res://art/lpc/body_light.png",
		"res://art/lpc/hair_long_white.png",
		"res://art/lpc/torso_robe_blue.png",
		"res://art/lpc/weapon_wand.png",
	],
	"warrior": [
		"res://art/lpc/body_female_light.png",
		"res://art/lpc/hair_female_plain_black.png",
		"res://art/lpc/torso_plate_female.png",
		"res://art/lpc/weapon_longsword_female.png",
	],
	"healer": [
		"res://art/lpc/body_light.png",
		"res://art/lpc/hair_long_blonde.png",
		"res://art/lpc/torso_robe_white.png",
		"res://art/lpc/weapon_wand.png",
	],
}

var _layers      : Array   = []
var _facing_east : bool    = false   # sheet faces left; flip for east
var _walking     : bool    = false
var _cast_loop   : bool    = false
var _busy        : bool    = false   # one-shot anim in progress

var _anim_timer  : float   = 0.0
var _anim_frame  : int     = 0
var _cur_row     : int     = ROW_WALK
var _cur_frames  : int     = FRAMES_WALK
var _fps         : float   = 8.0
var _on_done     : Callable = Callable()

var _walk_timer  : float   = 0.0
var _walk_frame  : int     = 0

func setup(char_id : String) -> void:
	for c in get_children():
		c.queue_free()
	_layers.clear()
	var paths : Array = CHAR_LAYERS.get(char_id, CHAR_LAYERS["wizard"])
	for p in paths:
		if not ResourceLoader.exists(p):
			continue
		var s          := Sprite2D.new()
		s.texture       = load(p)
		s.hframes       = SHEET_COLS
		s.vframes       = int(s.texture.get_height() / FRAME_H)
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.centered      = true
		add_child(s)
		_layers.append(s)
	scale = Vector2(1.0, 1.0)
	_set_all(ROW_WALK, 0)

func is_busy() -> bool:
	return _busy or _cast_loop

func set_facing(dir : String) -> void:
	_facing_east = (dir == "east")
	for s in _layers:
		if is_instance_valid(s):
			s.flip_h = _facing_east

func set_walking(val : bool) -> void:
	if _busy or _cast_loop:
		return
	_walking = val
	if not val:
		_walk_frame = 0
		_walk_timer = 0.0
		rotation    = 0.0
		_set_all(ROW_WALK, 0)

func play_anim(anim : String, fps : float, on_done : Callable = Callable()) -> void:
	var row    : int = ROW_SLASH
	var frames : int = FRAMES_SLASH
	match anim:
		"cast":  row = ROW_CAST;  frames = FRAMES_CAST
		"attack": row = ROW_SLASH; frames = FRAMES_SLASH
		"hurt":  row = ROW_HURT;  frames = FRAMES_HURT
	_walking     = false
	_busy        = true
	_cast_loop   = false
	_cur_row     = row
	_cur_frames  = frames
	_fps         = fps
	_on_done     = on_done
	_anim_frame  = 0
	_anim_timer  = 0.0
	_set_all(row, 0)

func start_cast_loop(fps : float = 8.0) -> void:
	_walking    = false
	_busy       = false
	_cast_loop  = true
	_cur_row    = ROW_CAST
	_cur_frames = FRAMES_CAST
	_fps        = fps
	_anim_frame = 0
	_anim_timer = 0.0
	_set_all(ROW_CAST, 0)

func stop_cast_loop() -> void:
	_cast_loop  = false
	_busy       = false
	_anim_frame = 0
	_set_all(ROW_WALK, 0)

func _process(delta : float) -> void:
	if _busy:
		_anim_timer += delta
		if _anim_timer >= 1.0 / _fps:
			_anim_timer  = 0.0
			_anim_frame += 1
			if _anim_frame >= _cur_frames:
				_busy       = false
				_anim_frame = 0
				_set_all(ROW_WALK, 0)
				if _on_done.is_valid():
					_on_done.call()
				return
			_set_all(_cur_row, _anim_frame)
	elif _cast_loop:
		_anim_timer += delta
		if _anim_timer >= 1.0 / _fps:
			_anim_timer = 0.0
			_anim_frame = (_anim_frame + 1) % _cur_frames
			_set_all(_cur_row, _anim_frame)
	elif _walking:
		_walk_timer += delta
		if _walk_timer >= 1.0 / 12.0:
			_walk_timer = 0.0
			_walk_frame = (_walk_frame + 1) % FRAMES_WALK
			_set_all(ROW_WALK, _walk_frame)
			# Side-to-side body rock synced to step
			rotation = sin(_walk_frame * PI / (FRAMES_WALK * 0.5)) * 0.10
	else:
		rotation = 0.0

func _set_all(row : int, col : int) -> void:
	var idx : int = row * SHEET_COLS + col
	for s in _layers:
		if is_instance_valid(s) and idx < s.hframes * s.vframes:
			s.frame = idx
