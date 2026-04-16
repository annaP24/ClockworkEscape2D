extends Node2D

@onready var scene_placeholder: Node2D = $Scene
@onready var world_map: Node2D = $WorldMap

var current_level_instance : Level = null
var current_level_index : int = 0
var current_level_path : String = ""
var is_level_manager_visible : bool = true
var max_level_reached : int = 1
var joypad_connected : bool = false

func _ready() -> void:
	#AudioManager.play_music("main_theme")
	_set_start_menu_visible(true)
	_set_world_map_visible(is_level_manager_visible)
	_pause_world_map(true)
	max_level_reached = GameManager.load_progress()
	world_map.unlock_levels()
	FadeScreen.connect("fade_out_finished", _on_fade_out_finished)
	EventBus.connect("sm_start_game", _on_sm_start_game)
	EventBus.connect("sm_quit_game", _on_sm_quit_game)
	EventBus.connect("sm_settings", _on_sm_settings)
	EventBus.connect("lb_quit_level", _on_quit_level_received)
	EventBus.connect("lb_restart_level", _on_restart_level_received)
	EventBus.connect("lb_return_to_map", _on_return_to_map_received)

	_check_input_controller()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("return"):
		_set_start_menu_visible(true)
		_pause_world_map(true)

func _set_start_menu_visible(sm_is_visible : bool):
	EventBus.world_hide_sm.emit(sm_is_visible)

func _set_world_map_visible(is_world_map_visible : bool):
	world_map.visible = is_world_map_visible

func _pause_world_map(is_paused : bool):
	get_tree().paused = is_paused

func _set_camera_enabled(is_camera_enabled : bool):
	world_map.camera_2d.enabled = is_camera_enabled

func load_level(path_to_level : String, level_id : int):
	if path_to_level != "":
		current_level_path = path_to_level
		#Cleanup previous level
		_unload_level()

		if current_level_path != "":
			#Dynamic load
			var level_scene = load(path_to_level)
			current_level_instance = level_scene.instantiate()
			current_level_instance.level_id = level_id
			scene_placeholder.call_deferred("add_child", current_level_instance)
		is_level_manager_visible = false
		_set_world_map_visible(is_level_manager_visible)
		_set_camera_enabled(false)

func _unload_level():
	if current_level_instance:
		current_level_instance.queue_free()

func _check_input_controller():
	var joypads = Input.get_connected_joypads()
	if joypads.size() > 0:
		joypad_connected = true
	else:
		joypad_connected = false
	world_map.set_joypad_connected(joypad_connected)

	# Subscribe to joypad connection
	Input.joy_connection_changed.connect(_on_joypad_connection_changed)

# --------------- Signals -----------------------
func  _on_player_finished():
	_unload_level()
	is_level_manager_visible = true
	FadeScreen.fade_out()

func _on_fade_out_finished():
	if is_level_manager_visible:
		_unload_level()
		# Enable world map visibility and enable camera
		# Disable visibility of start menu
		_set_world_map_visible(is_level_manager_visible)
		_pause_world_map(false)
		_set_camera_enabled(is_level_manager_visible)
		_set_start_menu_visible(false)
		FadeScreen.fade_in()
	else:
		load_level(current_level_path, GameManager.level_id)

func _on_quit_level_received():
	is_level_manager_visible = true
	FadeScreen.fade_out()

func _on_restart_level_received():
	_pause_world_map(false)
	is_level_manager_visible = false
	FadeScreen.fade_out()

func _on_return_to_map_received(level_id : int):
	#In case there is no other level, main manu will be shown
	is_level_manager_visible = true
	#Save level reached progress
	if level_id + 1 > max_level_reached:
		max_level_reached += 1
		GameManager.save_progress(max_level_reached)
	world_map.unlock_levels()
	#In case there is another leve, it will be loaded and level manager visibility disabled
	#ToDo: Switch to End Game screen if there are no other levels, from there to MainMenu
	#load_level(GameManager.get_next_level_path())
	#FadeScreen.fade_out()
	is_level_manager_visible = true
	FadeScreen.fade_out()


func _on_sm_start_game():
	_set_start_menu_visible(false)
	_pause_world_map(false)

func _on_sm_settings() -> void:
	pass # Replace with function body.

func _on_sm_quit_game() -> void:
	get_tree().quit()

func _on_joypad_connection_changed(_device: int, connected: bool):
	if connected:
		joypad_connected = true
	else:
		joypad_connected = false
	world_map.set_joypad_connected(joypad_connected)
