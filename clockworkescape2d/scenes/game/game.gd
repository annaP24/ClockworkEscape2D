extends Node2D

@onready var scene_placeholder: Node2D = $Scene

var current_level_instance : Level = null
var current_level_path : String = ""
var max_level_reached : int = 1

func _ready():
	EventBus.menu_quit_game.connect(_on_sm_quit_game)

func load_level(path_to_level : String, level_id : int):
	if path_to_level != "":
		current_level_path = path_to_level
		# Cleanup previous level
		_unload_level()

		if current_level_path != "":
			#Dynamic load
			var level_scene = load(path_to_level)
			current_level_instance = level_scene.instantiate()
			current_level_instance.level_id = level_id
			scene_placeholder.call_deferred("add_child", current_level_instance)


func _unload_level():
	if current_level_instance:
		current_level_instance.queue_free()

#---------------- Signals ----------------------------------
func _on_sm_quit_game() -> void:
	get_tree().quit()

func _on_quit_level_received() -> void:
	_unload_level()
