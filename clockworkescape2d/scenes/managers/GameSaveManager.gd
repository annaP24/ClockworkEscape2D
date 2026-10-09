extends Node

var current_level : int = 0
var current_level_id : int = 0
var all_level_paths : Array[String] = []
var levels_path : String = "res://scenes/levels/scenes/"

const PROGRESS_PATH = "res://"
const LEVELS_PATH = "res://levels.cfg"
const COLLECTED_IN_LEVEL_TAG = "collected_per_level" # legacy: count per level
const COLLECTED_MASK_TAG = "collected_mask"
const MID_SCENE_SEEN_TAG = "mid_scene_seen"
const END_SCENE_SEEN_TAG = "end_scene_seen"
const MAX_LEVEL_TAG = "max_level"
const MAX_COLLECTED_TAG = "max_collected"
const TOTAL_DEATHS_TAG = "deaths"
const TOTAL_TIME_PLAYED_TAG = "play_time_seconds"
const NR_OF_LEVLES_TAG = "nr_of_levels"
const MAX_NUM_OF_LEVELS = 20
const TOTAL_COLLECTABLES = MAX_NUM_OF_LEVELS * 3

var max_level_reached : int
var max_collected : int = 0
var session_start_time : int = 0
var total_play_time_seconds : int = 0
var current_save_slot : int = -1
var current_progress_path : String = ""
var max_deaths_for_slot : int = 0
var slot_data : Dictionary = {
	"deaths" : 0,
	"playtime": 0,
	"collectables": 0,
	"level": 0
}

var is_joypad_connected : bool = false
var mouse_forced_hidden : bool = false

func _check_input_controller():
	var joypads = Input.get_connected_joypads()
	if joypads.size() > 0:
		is_joypad_connected = true
	else:
		is_joypad_connected = false

	#update_mouse_visibility(mouse_forced_hidden)
	if not Input.joy_connection_changed.is_connected(_on_joypad_connection_changed):
		# Subscribe to joypad connection
		Input.joy_connection_changed.connect(_on_joypad_connection_changed)

func update_mouse_visibility(force_hidden: bool = false) -> void:
	mouse_forced_hidden = force_hidden
	if mouse_forced_hidden or is_joypad_connected:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_joypad_connection_changed(_device: int, connected: bool):
	is_joypad_connected = connected
	update_mouse_visibility(mouse_forced_hidden)

func _ready() -> void:
	set_level_paths()
	_check_input_controller()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mute"):
		var is_muted = SettingManager.toggle_mute()
		if is_muted:
			AudioManager.mute_all_sound(true)
		else:
			AudioManager.mute_all_sound(false)
	_check_input_controller()

func set_current_slot_id(slot_id: int) -> void:
	if slot_id < 1 or slot_id > 3:
		current_progress_path = ""
		current_save_slot = -1
		return
	current_progress_path = _get_file_name(slot_id)
	current_save_slot = slot_id

func load_progress() -> int:
	var cf = ConfigFile.new()
	#Check if file exists
	if !FileAccess.file_exists(current_progress_path):
		print("No cfg file found creating one")
		_create_default_progress(current_progress_path)
		start_play_session()
		return max_level_reached

	if cf.load(current_progress_path) == OK:
		start_play_session()
		max_level_reached = cf.get_value("progress", MAX_LEVEL_TAG,1)
		max_collected = cf.get_value("progress", MAX_COLLECTED_TAG,1)
		total_play_time_seconds = cf.get_value("progress", TOTAL_TIME_PLAYED_TAG,0.0)
		max_deaths_for_slot = cf.get_value("progress", TOTAL_DEATHS_TAG,0)
		return max_level_reached
	return 0

func _get_file_name(slot_id : int) -> String:
	var file = PROGRESS_PATH + "progress_slot_" + str(slot_id) + ".cfg"
	return file

func save_progress(new_max_level : int ):
	var cf = ConfigFile.new()
	#Check if dile exists
	if FileAccess.file_exists(current_progress_path):
		cf.load(current_progress_path)
	#Update value
	cf.set_value("progress", MAX_LEVEL_TAG, new_max_level)
	#Write to disk
	cf.save(current_progress_path)

func get_collected_count_for_level(level_id : int) -> int:
	var cfg = ConfigFile.new()
	if cfg.load(current_progress_path) == OK:
		return _count_bits(_read_mask(cfg, level_id))
	return 0

## Bit i is set when collectable i of the level was collected on a completed run.
func get_collected_mask(level_id : int) -> int:
	var cfg = ConfigFile.new()
	if cfg.load(current_progress_path) == OK:
		return _read_mask(cfg, level_id)
	return 0

func _read_mask(cfg : ConfigFile, level_id : int) -> int:
	if cfg.has_section_key(COLLECTED_MASK_TAG, str(level_id)):
		return int(cfg.get_value(COLLECTED_MASK_TAG, str(level_id), 0))
	# Old saves stored only a count; treat it as the first n collectables.
	var legacy_count : int = int(cfg.get_value(COLLECTED_IN_LEVEL_TAG, str(level_id), 0))
	return (1 << legacy_count) - 1

func _count_bits(mask : int) -> int:
	var n := 0
	while mask > 0:
		n += mask & 1
		mask >>= 1
	return n

func get_total_collected() -> int:
	var cfg = ConfigFile.new()
	if cfg.load(current_progress_path) != OK:
		return 0
	var total := 0
	for i in range(1, MAX_NUM_OF_LEVELS + 1):
		total += _count_bits(_read_mask(cfg, i))
	return total

func is_scene_seen(tag : String) -> bool:
	var cfg = ConfigFile.new()
	if cfg.load(current_progress_path) != OK:
		return false
	return cfg.get_value("progress", tag, false)

func mark_scene_seen(tag : String) -> void:
	var cfg = ConfigFile.new()
	if cfg.load(current_progress_path) != OK:
		return
	cfg.set_value("progress", tag, true)
	cfg.save(current_progress_path)

func delete_configuration(slot : int):
	var path_name = _get_file_name(slot)
	#Check if dile exists
	if FileAccess.file_exists(path_name):
		var err = DirAccess.remove_absolute(path_name)

		if err == OK:
			print("Deleted save slot ", slot)
			return true
		else:
			push_error("Failed to delete save slot %d. Error: %d" % [slot, err])
			return false

func _create_default_progress(filename : String):
	var cf := ConfigFile.new()
	#------------ MAX/MIN Level reached ------------------
	cf.set_value("progress", MAX_LEVEL_TAG, 1) # Starting at level 1
	cf.set_value("progress", MAX_COLLECTED_TAG, 0)
	cf.set_value("progress", TOTAL_DEATHS_TAG, max_deaths_for_slot) # Starting at level 1
	cf.set_value("progress", TOTAL_TIME_PLAYED_TAG, 0) # Starting at level 1

	#-------- Levels progress ----------------------------
	#Initialize empty array of level-collectables_nr for progress
	for i in range(1,MAX_NUM_OF_LEVELS + 1):
		cf.set_value(COLLECTED_MASK_TAG, str(i), 0)

	#------ Settings -------------------------------------
	SettingManager.create_default_settings(cf)
	cf.save(filename)
	max_level_reached = 1

## Merges the collectables picked up in a completed run into the saved mask.
func commit_level_collectables(level_id : int, run_mask : int):
	var cf = ConfigFile.new()
	if FileAccess.file_exists(current_progress_path):
		cf.load(current_progress_path)
	var saved_mask := _read_mask(cf, level_id)
	var new_mask := saved_mask | run_mask
	if new_mask == saved_mask and cf.has_section_key(COLLECTED_MASK_TAG, str(level_id)):
		return
	cf.set_value(COLLECTED_MASK_TAG, str(level_id), new_mask)
	cf.save(current_progress_path)
	_update_total_collected()

func _update_total_collected():
	var cf = ConfigFile.new()
	if FileAccess.file_exists(current_progress_path):
		cf.load(current_progress_path)
	max_collected = 0
	for i in range(1, MAX_NUM_OF_LEVELS + 1):
		max_collected += _count_bits(_read_mask(cf, i))
	cf.set_value("progress", MAX_COLLECTED_TAG, max_collected)
	cf.save(current_progress_path)

func set_level_paths():
	all_level_paths.clear()
	var nr_of_levels : int
	var cfg = ConfigFile.new()
	if FileAccess.file_exists(LEVELS_PATH):
		if cfg.load(LEVELS_PATH) == OK:
			nr_of_levels = cfg.get_value(NR_OF_LEVLES_TAG, "max")
			for i in range(1, nr_of_levels + 1):
				all_level_paths.append(levels_path + cfg.get_value("level_order", str(i)))

func get_next_level_path() -> String:
	current_level += 1
	if current_level <= all_level_paths.size()-1:
		return all_level_paths[current_level]
	else:
		#ToDo The end screen, return to menu
		return ""

func get_level_path() -> String:
	if all_level_paths.is_empty():
		set_level_paths()
	if current_level >= 0 and current_level <= all_level_paths.size()-1:
		return all_level_paths[current_level]
	else:
		#ToDo The end screen, return to menu
		return ""

func update_number_of_deaths():
	max_deaths_for_slot += 1
	# TODO: do this once when player quits, goes back to main menu
	_update_number_of_deaths()

func _update_number_of_deaths():
	var cf = ConfigFile.new()
	#Check if file exists
	if FileAccess.file_exists(current_progress_path):
		cf.load(current_progress_path)

	#Update value
	cf.set_value("progress", TOTAL_DEATHS_TAG, max_deaths_for_slot)
	#Write to disk
	cf.save(current_progress_path)

func _update_play_time():
	var cf = ConfigFile.new()
	#Check if file exists
	if FileAccess.file_exists(current_progress_path):
		cf.load(current_progress_path)

	#Update value
	cf.set_value("progress", TOTAL_TIME_PLAYED_TAG, get_total_play_time())
	#Write to disk
	cf.save(current_progress_path)

func start_play_session():
	# Cast to int immediately to keep everything consistent
	session_start_time = int(Time.get_unix_time_from_system())

func get_current_session_time() -> int:
	# If session_start_time is 0, it means we haven't called start_play_session()
	if session_start_time == 0:
		return 0
	return int(Time.get_unix_time_from_system() - session_start_time)

func get_total_play_time() -> int:
	return total_play_time_seconds + get_current_session_time()

func save_stats_progress():
	var cf = ConfigFile.new()

	if FileAccess.file_exists(current_progress_path):
		cf.load(current_progress_path)
	#Update value
	cf.set_value("progress", TOTAL_TIME_PLAYED_TAG, get_total_play_time())
	cf.set_value("progress", TOTAL_DEATHS_TAG, max_deaths_for_slot)
	#Write to disk
	cf.save(current_progress_path)

func check_progress_data_for_slot(slot_id: int) -> Dictionary:
	var cf = ConfigFile.new()
	var file_name = _get_file_name(slot_id)
	var dic : Dictionary = {}
	#Check if dile exists
	if !FileAccess.file_exists(file_name):
		return dic

	if cf.load(file_name) == OK:
		dic["level"] = cf.get_value("progress", MAX_LEVEL_TAG, 1)
		dic["collected"] = cf.get_value("progress", MAX_COLLECTED_TAG, 0)
		dic["time"] = cf.get_value("progress", TOTAL_TIME_PLAYED_TAG, 0)
		dic["deaths"] = cf.get_value("progress", TOTAL_DEATHS_TAG, 0)
		dic["progress"] = get_completion_percentage(float(dic["level"]), float(dic["collected"]))
		return dic
	return dic

func format_play_time(total_seconds: float) -> String:
	# Ensure we are working with whole numbers
	var total_seconds_int : int = int(total_seconds)
	var hours = int(total_seconds_int / 3600)
	var minutes = int((total_seconds_int % 3600) / 60)
	var seconds = int(total_seconds_int % 60)
	if hours > 0:
		return "%02d:%02d:%02d" % [hours, minutes, seconds]
	else:
		return "%02d:%02d" % [minutes, seconds]
	#TODO: if we want to show hours, we can add it to the string
func get_completion_percentage(max_level : float, max_collected_coll : float) -> float:

	var level_progress = max_level / MAX_NUM_OF_LEVELS
	var collectable_progress = max_collected_coll / TOTAL_COLLECTABLES

	return level_progress * 0.6 + collectable_progress * 0.4
