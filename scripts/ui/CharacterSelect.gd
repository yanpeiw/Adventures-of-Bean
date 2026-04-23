extends Control

@onready var back_btn    : Button = $TopBar/BackButton
@onready var warrior_btn : Button = $CharRow/WarriorBtn
@onready var healer_btn  : Button = $CharRow/HealerBtn
@onready var wizard_btn  : Button = $CharRow/WizardBtn

func _ready() -> void:
	back_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn"))
	warrior_btn.pressed.connect(func(): _select("warrior"))
	healer_btn.pressed.connect(func():  _select("healer"))
	wizard_btn.pressed.connect(func():  _select("wizard"))
	_build_buttons()

func _build_buttons() -> void:
	var chars = ["warrior", "healer", "wizard"]
	var btns  = [warrior_btn, healer_btn, wizard_btn]
	for i in 3:
		var char_id   : String     = chars[i]
		var char_data : Dictionary = GameState.CHARACTERS.get(char_id, {})
		var unlocked  : bool       = char_id in GameState.unlocked_characters
		var selected  : bool       = char_id == GameState.selected_character
		btns[i].text     = "%s\n❤ x%d\n%s" % [
			char_data.get("name", "?"),
			char_data.get("max_hearts", 0),
			"[Selected]" if selected else ("Unlock" if not unlocked else "Select")
		]
		btns[i].disabled = not unlocked

func _select(char_id : String) -> void:
	GameState.select_character(char_id)
	get_tree().change_scene_to_file("res://scenes/hub/HubScene.tscn")
