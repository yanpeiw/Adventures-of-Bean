extends Control

@onready var floor_label  : Label  = $CenterContainer/VBox/FloorLabel
@onready var gold_label   : Label  = $CenterContainer/VBox/GoldLabel
@onready var retry_btn    : Button = $CenterContainer/VBox/RetryButton
@onready var menu_btn     : Button = $CenterContainer/VBox/MenuButton

func _ready() -> void:
	floor_label.text = "Reached Floor %d" % GameState.current_floor
	gold_label.text  = "Gold: %d" % GameState.gold
	GameState.die()
	retry_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/ui/TowerSelect.tscn"))
	menu_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/hub/HubScene.tscn"))
