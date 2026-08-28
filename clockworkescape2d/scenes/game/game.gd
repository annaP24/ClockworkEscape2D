extends Node2D

@onready var scene_placeholder: Node2D = $Scene

var current_level_instance : Level = null
var current_level_path : String = ""
var max_level_reached : int = 1

func _ready():
	GameSession._check_input_controller()
	GameSession.update_mouse_visibility(false)
	EventBus.menu_quit_game.connect(_on_sm_quit_game)

#---------------- Signals ----------------------------------
func _on_sm_quit_game() -> void:
	get_tree().quit()
