extends Node2D
class_name World
@onready var state_machine: Node = $FSM/StateMachine
@onready var scene: Node2D = $Scene
func _ready():
	GameSession._check_input_controller()
	GameSession.update_mouse_visibility(false)
	EventBus.menu_quit_game.connect(_on_sm_quit_game)

#---------------- Signals ----------------------------------
func _on_sm_quit_game() -> void:
	get_tree().quit()

func get_camera() -> Camera2D:
	if state_machine.current_state == state_machine.states["level"]:
		var level = scene.get_child(0) as Level
		return level.get_camera()

	return null
func freeze_player():
	if state_machine.current_state == state_machine.states["level"]:
		var level = scene.get_child(0) as Level
		level.freeze_player()

func set_gameplay_frozen(frozen: bool) -> void:
	if state_machine.current_state == state_machine.states["level"]:
		var level = scene.get_child(0) as Level
		level.set_gameplay_frozen(frozen)