extends Control

@onready var back_btn    : Button = $TopBar/BackButton
@onready var ashen_btn   : Button = $TowerRow/AshenBtn
@onready var drowned_btn : Button = $TowerRow/DrownedBtn
@onready var brass_btn   : Button = $TowerRow/BrassBtn

const TOWER_IDS  : Array = ["ashen_keep", "drowned_vaults", "brass_citadel"]

func _ready() -> void:
	back_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/hub/HubScene.tscn"))
	ashen_btn.pressed.connect(func():   _enter("ashen_keep"))
	drowned_btn.pressed.connect(func(): _enter("drowned_vaults"))
	brass_btn.pressed.connect(func():   _enter("brass_citadel"))
	_build_cards()

func _build_cards() -> void:
	var btns : Array = [ashen_btn, drowned_btn, brass_btn]
	for i in 3:
		var tid      : String     = TOWER_IDS[i]
		var tdata    : Dictionary = GameState.TOWERS.get(tid, {})
		var unlocked : bool       = tid in GameState.unlocked_towers
		var completed : int       = GameState.tower_floors_completed.get(tid, 0)
		var total     : int       = tdata.get("floors", 36)
		var req       : String    = tdata.get("unlock_req", "")

		var status : String
		if not unlocked:
			var req_name : String = GameState.TOWERS.get(req, {}).get("name", "???")
			status = "LOCKED\nClear %s\nto unlock" % req_name
		elif completed >= total:
			status = "CONQUERED\n%d / %d" % [completed, total]
		elif completed > 0:
			status = "Floor %d / %d" % [completed + 1, total]
		else:
			status = "Enter"

		btns[i].text     = "%s\n\n%s\n\n%s" % [
			tdata.get("name", "?"),
			tdata.get("description", ""),
			status
		]
		btns[i].disabled = not unlocked

func _enter(tower_id : String) -> void:
	GameState.select_tower(tower_id)
	GameState.start_run()
	get_tree().change_scene_to_file("res://scenes/floors/FloorBase.tscn")
