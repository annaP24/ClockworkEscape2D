extends Node

var collected_objects : int = 0
var wall_jump_coaf : float = 1.0	
var current_level : int = 1
var all_level_paths : Array[String]
var levels_path : String = "res://scenes/levels/scenes/"

func _ready() -> void:
	set_level_paths()
	print("Levels ",  all_level_paths)

func read_folder() -> Array:
	var dir = DirAccess.open(levels_path)
	if dir:
		return dir.get_files()
	else:
		return []

func set_level_paths():
	for file in read_folder():
		all_level_paths.append(levels_path + file)

func get_next_level_path() -> String:
	current_level += 1
	if current_level - 1 <= all_level_paths.size()-1:
		return all_level_paths[current_level - 1]
	else:
		#ToDo The end screen, return to menu
		return ""
