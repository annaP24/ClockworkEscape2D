extends Node2D

@onready var scene_placeholder: Node2D = $Scene
@onready var world_map: Node2D = $WorldMap

var current_level_instance : Level = null
var current_level_index : int = 0
var current_level_path : String = ""
var is_level_manager_visible : bool = true
var max_level_reached : int = 1
const SAVE_PATH : String = "res://progress.cfg"

func _ready() -> void:
	world_map.visible = is_level_manager_visible
	#world_map.load_level.connect(_on_load_level)
	load_progress()
	world_map.unlock_levels()
	FadeScreen.connect("fade_out_finished", _on_fade_out_finished)
	print(get_tree().current_scene.name)

func load_progress():
	var cf = ConfigFile.new()
	#Check if dile exists
	if !FileAccess.file_exists(SAVE_PATH):
		print("No cfg file found creating one")
		create_default_progress()
		return

	if cf.load(SAVE_PATH) == OK:
		max_level_reached = cf.get_value("progress","max",1)
		print("Cfg found, max level reached is: ", max_level_reached)

func save_progress():
	var cf = ConfigFile.new()
	#Check if dile exists
	if FileAccess.file_exists(SAVE_PATH):
		cf.load(SAVE_PATH)
	#Update value
	cf.set_value("progress", "max", max_level_reached)
	#Write to disk
	cf.save(SAVE_PATH)
	print("Progress saved, new max level: ", max_level_reached)

func create_default_progress():
	var cf := ConfigFile.new()
	cf.set_value("progress", "max", 1) # Starting at level 1
	cf.save(SAVE_PATH)
	max_level_reached = 1
	print("Created new progress file at:", SAVE_PATH)

func load_level(path_to_level : String):
	if path_to_level != "":
		current_level_path = path_to_level
		#Cleanup previous level
		unload_level()

		if current_level_path != "":
			#Dynamic load
			var level_scene = load(path_to_level)
			current_level_instance = level_scene.instantiate()
			current_level_instance.connect("quit_level", _on_quit_level_received)
			current_level_instance.connect("restart_level", _on_restart_level_received)
			current_level_instance.connect("load_next_level", _on_load_next_level_received)
			scene_placeholder.call_deferred("add_child", current_level_instance)
		is_level_manager_visible = false
		world_map.visible = is_level_manager_visible
		world_map.camera_2d.enabled = false

func level_selected(path_to_level : String):
	current_level_path = path_to_level
	is_level_manager_visible = false
	FadeScreen.fade_out()

func restart_level():
	FadeScreen.fade_out()

func unload_level():
	if current_level_instance:
		current_level_instance.queue_free()

func  _on_player_finished():
	unload_level()
	is_level_manager_visible = true
	FadeScreen.fade_out()

func _on_fade_out_finished():
	if is_level_manager_visible:
		unload_level()
		world_map.visible = is_level_manager_visible
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

func _on_load_next_level_received():
	#In case there is no other level, main manu will be shown
	is_level_manager_visible = true
	max_level_reached += 1
	save_progress()
	world_map.unlock_levels()
	#In case there is another leve, it will be loaded and level manager visibility disabled
	#ToDo: Switch to End Game screen if there are no other levels, from there to MainMenu
	load_level(GameManager.get_next_level_path())
	FadeScreen.fade_out()
