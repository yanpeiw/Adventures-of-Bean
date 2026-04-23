extends Node2D

@onready var player        : CharacterBody2D = $Player
@onready var exit_area     : Area2D          = $Exit
@onready var joystick_base : Control         = $JoystickBase
@onready var joystick_knob : Control         = $JoystickKnob
@onready var hud_floor     : Label           = $UILayer/HUD/FloorLabel
@onready var hud_hearts    : Label           = $UILayer/HUD/HeartsLabel

func _ready() -> void:
	joystick_base.visible = false
	joystick_knob.visible = false
	hud_floor.text  = "%s — Floor %d / %d" % [GameState.get_tower_name(), GameState.current_floor, GameState.get_tower_floor_count()]
	hud_hearts.text = "Hearts: %d / %d" % [GameState.current_hearts, GameState.get_max_hearts()]
	exit_area.body_entered.connect(_on_exit_entered)

func _on_exit_entered(body : Node2D) -> void:
	if body == player:
		GameState.advance_floor()
		get_tree().change_scene_to_file("res://scenes/hub/HubScene.tscn")
