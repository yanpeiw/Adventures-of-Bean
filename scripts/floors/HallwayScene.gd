extends Node2D

@onready var player     : CharacterBody2D = $Player
@onready var exit_door  : Area2D          = $ExitDoor
@onready var room_label : Label           = $UILayer/RoomLabel

func _ready() -> void:
	var cam : Camera2D = player.get_node("Camera2D")
	cam.limit_left   = 0
	cam.limit_top    = 0
	cam.limit_right  = 1280
	cam.limit_bottom = 720

	room_label.text = "Room %d" % GameState.current_room
	exit_door.body_entered.connect(_on_exit_reached)

func _on_exit_reached(body : Node) -> void:
	if body == player:
		get_tree().change_scene_to_file("res://scenes/floors/FloorBase.tscn")
