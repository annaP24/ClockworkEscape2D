extends Node
var collected_objects : int = 0
var wall_jump_coaf : float = 1.0
var current_level : int = 0
var all_level_paths : Array[String]
var levels_path : String = "res://scenes/levels/scenes/"
var current_page : int = 0

const CONFIG_PATH = "res://progress.cfg"
const LEVELS_PATH = "res://levels.cfg"
var max_level_reached : int
var nr_of_collected : int = 0
var max_collectable : int = 0

func _ready() -> void:
	set_level_paths()
	load_progress()
	
func load_progress() -> int:
	var cf = ConfigFile.new()
	#Check if dile exists
	if !FileAccess.file_exists(CONFIG_PATH):
		print("No cfg file found creating one")
		create_default_progress()
		return max_level_reached

	if cf.load(CONFIG_PATH) == OK:
		max_level_reached = cf.get_value("progress","max",1)
		print("Cfg found, max level reached is: ", max_level_reached)
		return max_level_reached
	return 0
	
func save_progress(new_max_level : int ):
	var cf = ConfigFile.new()
	#Check if dile exists
	if FileAccess.file_exists(CONFIG_PATH):
		cf.load(CONFIG_PATH)
	#Update value
	cf.set_value("progress", "max", new_max_level)
	#Write to disk
	cf.save(CONFIG_PATH)
	print("Progress saved, new max level: ", new_max_level)

func load_collectables_count(level_id : int) -> int:
	var cf = ConfigFile.new()

	if cf.load(CONFIG_PATH) == OK:
		var ret_value = cf.get_value("collectables",  "l%s_collected" % level_id)
		print("Cfg found, colected is: ", ret_value)
		return ret_value
	return 0	

func load_mx_collectables_count(level_id : int) -> int:
	var cfg = ConfigFile.new()
	if cfg.load(CONFIG_PATH) == OK:
		var ret_value = cfg.get_value("collectables", "l%s_collectables_max" % level_id)	
		print("Cfg found, max to collect is: ", ret_value)
		return ret_value
	return 0
	
func create_default_progress():
	var cf := ConfigFile.new()
	cf.set_value("progress", "max", 1) # Starting at level 1
	cf.save(CONFIG_PATH)
	max_level_reached = 1
	print("Created new progress file at:", CONFIG_PATH)

func set_level_paths():
	var nr_of_levels : int
	var cfg = ConfigFile.new()
	if FileAccess.file_exists(LEVELS_PATH):
		if cfg.load(LEVELS_PATH) == OK:
			nr_of_levels = cfg.get_value("nr_of_levels", "max")
			for i in range(1, nr_of_levels):
				all_level_paths.append(levels_path + cfg.get_value("level_order", str(i)))

func get_next_level_path() -> String:
	current_level += 1
	if current_level <= all_level_paths.size()-1:
		return all_level_paths[current_level]
	else:
		#ToDo The end screen, return to menu
		return ""
