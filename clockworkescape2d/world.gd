extends Node2D

@onready var scene_placeholder: Node2D = $Scene
@onready var player_scene : PackedScene = preload("res://scenes/character/character_64x64.tscn")
@onready var level_manager: Control = $LevelManager

var current_level_instance : Level_64x64 = null
var current_level_index : int = 0
var player_instance : PlayerFSM
var current_level_path : String = ""
var is_level_manager_visible : bool = true

func _ready() -> void:
	level_manager.visible = is_level_manager_visible
	#FadeScreen.connect("fade_in_finished", _on_fade_in_finished)
	FadeScreen.connect("fade_out_finished", _on_fade_out_finished)
	#FadeScreen.level_transition()
	
func load_level(path_to_level : String):
	if path_to_level != "":
		current_level_path = path_to_level
		#Cleanup previous level
		if current_level_instance:
			current_level_instance.queue_free()
		if player_instance:
			player_instance.queue_free()
			
		if current_level_path != "":
			#Dynamic load
			var level_scene = load(path_to_level)
			current_level_instance = level_scene.instantiate() 
			current_level_instance.connect("quit_level", _on_quit_level_received)
			scene_placeholder.add_child(current_level_instance)
		is_level_manager_visible = false
		level_manager.visible = is_level_manager_visible

		
func spawn_player():
	player_instance = player_scene.instantiate() as PlayerFSM
	var marker = current_level_instance.get_marker()
	player_instance.position = marker.position
	current_level_instance.add_child(player_instance)
	player_instance.connect("player_died", _on_player_died)
	player_instance.connect("player_finished", _on_player_finished)
	
func restart_level():
	FadeScreen.fade_out()

func unload_level():
	if current_level_instance:
		current_level_instance.queue_free()
		
		
func _on_player_died():
	restart_level()

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
