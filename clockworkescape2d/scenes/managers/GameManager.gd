extends Node

var current_level : int = 0
var level_id : int = 0
var all_level_paths : Array[String]
var levels_path : String = "res://scenes/levels/scenes/"

const PROGRESS_PATH = "res://progress.cfg"
const LEVELS_PATH = "res://levels.cfg"
const COLLECTED_IN_LEVEL_TAG = "collected_per_level"
const MAX_LEVEL_TAG = "max_level"
const MAX_COLLECTED_TAG = "max_collected"
const NR_OF_LEVLES_TAG = "nr_of_levels"
const MAX_NUM_OF_LEVELS = 20
var collected_objects : int = 0
var max_level_reached : int
var max_collected : int = 0
var is_muted : bool = false
func _ready() -> void:
	set_level_paths()
	load_progress()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("mute"):
		if not is_muted:
			AudioManager.mute_all_sound(true)
			is_muted = true
		else:
			AudioManager.mute_all_sound(false)
			is_muted = false
func load_progress() -> int:
	var cf = ConfigFile.new()
	#Check if dile exists
	if !FileAccess.file_exists(PROGRESS_PATH):
		print("No cfg file found creating one")
		create_default_progress()
		return max_level_reached

	if cf.load(PROGRESS_PATH) == OK:
		max_level_reached = cf.get_value("progress",MAX_LEVEL_TAG,1)
		max_collected = cf.get_value("progress",MAX_COLLECTED_TAG,1)
		return max_level_reached
	return 0

func save_progress(new_max_level : int ):
	var cf = ConfigFile.new()
	#Check if dile exists
	if FileAccess.file_exists(PROGRESS_PATH):
		cf.load(PROGRESS_PATH)
	#Update value
	cf.set_value("progress", MAX_LEVEL_TAG, new_max_level)
	#Write to disk
	cf.save(PROGRESS_PATH)

func get_collected_count_for_level(level_id : int) -> int:
	var cfg = ConfigFile.new()
	if cfg.load(PROGRESS_PATH) == OK:
		var ret_value = cfg.get_value(COLLECTED_IN_LEVEL_TAG, str(level_id))
		return ret_value
	return 0

func create_default_progress():
	var cf := ConfigFile.new()
	cf.set_value("progress", MAX_LEVEL_TAG, 1) # Starting at level 1
	cf.set_value("progress", MAX_COLLECTED_TAG, 0) # Starting at level 1
	#Initialize empty array of level-collectables_nr for progress
	for i in range(1,MAX_NUM_OF_LEVELS + 1):
		cf.set_value(COLLECTED_IN_LEVEL_TAG, str(i), 0)
	cf.save(PROGRESS_PATH)
	max_level_reached = 1
	print("Created new progress file at:", PROGRESS_PATH)

func save_collectables_count_for_level(level_id : int, count : int):
	var cf = ConfigFile.new()
	#Check if dile exists
	if FileAccess.file_exists(PROGRESS_PATH):
		cf.load(PROGRESS_PATH)
	#Get current value
	var current_max = cf.get_value(COLLECTED_IN_LEVEL_TAG, str(level_id), 1)
	#If newly gathered collectables are more than previously saved number
	if count > current_max:
		#Update value
		cf.set_value(COLLECTED_IN_LEVEL_TAG, str(level_id), count)
		#Write to disk
		cf.save(PROGRESS_PATH)
		#If max count of collected per level increased
		_update_total_collected()


func _update_total_collected():
	var cf = ConfigFile.new()
	#Check if dile exists
	if FileAccess.file_exists(PROGRESS_PATH):
		cf.load(PROGRESS_PATH)
	max_collected = 0
	for i in range(1, MAX_NUM_OF_LEVELS + 1):
		max_collected += cf.get_value(COLLECTED_IN_LEVEL_TAG, str(i))
	#Update value
	cf.set_value("progress", MAX_COLLECTED_TAG, max_collected)
	#Write to disk
	cf.save(PROGRESS_PATH)
	print("Update max collected ", max_collected + collected_objects)
	collected_objects = 0

func set_level_paths():
	var nr_of_levels : int
	var cfg = ConfigFile.new()
	if FileAccess.file_exists(LEVELS_PATH):
		if cfg.load(LEVELS_PATH) == OK:
			nr_of_levels = cfg.get_value(NR_OF_LEVLES_TAG, "max")
			for i in range(1, nr_of_levels):
				all_level_paths.append(levels_path + cfg.get_value("level_order", str(i)))

func get_next_level_path() -> String:
	current_level += 1
	if current_level <= all_level_paths.size()-1:
		return all_level_paths[current_level]
	else:
		#ToDo The end screen, return to menu
		return ""

func get_level_path() -> String:
	if current_level <= all_level_paths.size()-1:
		return all_level_paths[current_level]
	else:
		#ToDo The end screen, return to menu
		return ""
