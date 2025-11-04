extends Node2D

@onready var scene_placeholder: Node2D = $Scene
@onready var level_manager: Control = $LevelManager

var current_level_instance : Level = null
var current_level_index : int = 0
var current_level_path : String = ""
var is_level_manager_visible : bool = true

func _ready() -> void:
	level_manager.visible = is_level_manager_visible
	FadeScreen.connect("fade_out_finished", _on_fade_out_finished)
	print(get_tree().current_scene.name)

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
			scene_placeholder.add_child(current_level_instance)
		is_level_manager_visible = false
		level_manager.visible = is_level_manager_visible
		
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
		level_manager.visible = is_level_manager_visible
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
	#For now load Main menu
	#ToDo: Load next level immediatley
	is_level_manager_visible = true
	FadeScreen.fade_out()
	
