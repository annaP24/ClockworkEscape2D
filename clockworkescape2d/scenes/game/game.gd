extends Node2D

func _ready():
	EventBus.menu_quit_game.connect(_on_sm_quit_game)

#---------------- Signals ----------------------------------
func _on_sm_quit_game() -> void:
	get_tree().quit()
