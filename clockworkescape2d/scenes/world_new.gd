extends Node2D

@onready var scene_placeholder: Node2D = $Scene
@onready var world_map: Node2D = $WorldMap

var current_level_instance : Level = null
var current_level_index : int = 0
var current_level_path : String = ""
var is_level_manager_visible : bool = true
var max_level_reached : int = 1

func _ready() -> void:
	world_map.visible = is_level_manager_visible
	#world_map.get_tree().paused = !is_level_manager_visible
	max_level_reached = GameManager.load_progress()
	world_map.unlock_levels()
	FadeScreen.connect("fade_out_finished", _on_fade_out_finished)

func load_level(path_to_level : String):
	if path_to_level != "":
		current_level_path = path_to_level
		#Cleanup previous level
		_unload_level()

		if current_level_path != "":
			#Dynamic load
			var level_scene = load(path_to_level)
			current_level_instance = level_scene.instantiate()
			current_level_instance.level_id = path_to_level.split("_")[1].to_int()
			current_level_instance.connect("quit_level", _on_quit_level_received)
			current_level_instance.connect("restart_level", _on_restart_level_received)
			current_level_instance.connect("load_next_level", _on_load_next_level_received)
			scene_placeholder.call_deferred("add_child", current_level_instance)
		is_level_manager_visible = false
		world_map.visible = is_level_manager_visible
		#world_map.get_tree().paused = !is_level_manager_visible
		world_map.camera_2d.enabled = false

func _unload_level():
	if current_level_instance:
		current_level_instance.queue_free()

func  _on_player_finished():
	_unload_level()
	is_level_manager_visible = true
	FadeScreen.fade_out()

func _on_fade_out_finished():
	if is_level_manager_visible:
		_unload_level()
		world_map.visible = is_level_manager_visible
		#world_map.get_tree().paused = !is_level_manager_visible
		world_map.camera_2d.enabled = is_level_manager_visible
		FadeScreen.fade_in()
	else:
		load_level(current_level_path)

func _on_quit_level_received():
	is_level_manager_visible = true
	FadeScreen.fade_out()

func _on_restart_level_received():
	is_level_manager_visible = false
	FadeScreen.fade_out()

func _on_load_next_level_received(level_id : int):
	#In case there is no other level, main manu will be shown
	is_level_manager_visible = true
	#Save level reached progress
	if level_id + 1 > max_level_reached:
		max_level_reached += 1
		GameManager.save_progress(max_level_reached)
	world_map.unlock_levels()
	#In case there is another leve, it will be loaded and level manager visibility disabled
	#ToDo: Switch to End Game screen if there are no other levels, from there to MainMenu
	load_level(GameManager.get_next_level_path())
	FadeScreen.fade_out()
