extends Node2D

@onready var scene_placeholder: Node2D = $Scene
@onready var world_map: WorldMap = $WorldMap
@onready var brightness_mat : Material = $BrightnessLayer.material
@onready var brightness_layer: ColorRect = $BrightnessLayer

enum GameState {
	MAIN_MENU,
	SAVE_SLOTS,
	SETTINGS,
	WORLD_MAP,
	IN_LEVEL
}
enum TransitionAction {
	NONE,
	RELOAD_LEVEL,
	RETURN_TO_MAP
}

var pending_transition : TransitionAction = TransitionAction.NONE
var current_state : GameState
var current_level_instance : Level = null
var current_level_path : String = ""
var max_level_reached : int = 1

func _ready() -> void:
	AudioManager.play_music("main_theme")
	_set_start_menu_visible(true)
	_set_world_map_visible(true)
	_pause_world_map(true)

	FadeScreen.connect("fade_out_finished", _on_fade_out_finished)
	EventBus.connect("sm_start_game", _on_sm_start_game)
	EventBus.connect("sm_show_game_slots", _on_sm_show_game_slots)
	EventBus.connect("sm_quit_game", _on_sm_quit_game)
	EventBus.connect("sm_settings", _on_sm_settings)
	EventBus.connect("lb_quit_level", _on_quit_level_received)
	EventBus.connect("lb_restart_level", _on_restart_level_received)
	EventBus.connect("lb_return_to_map", _on_return_to_map_received)
	EventBus.connect("s_brightness_changed", _on_brightness_changed)
	EventBus.connect("slot_pressed", _on_slot_pressed)

	_check_input_controller()
	_open_main_menu()

func _unhandled_input(event):

	if !event.is_action_pressed("return"):
		return

	match current_state:
		GameState.WORLD_MAP:
			GameManager.save_stats_progress()
			_open_main_menu()
		GameState.MAIN_MENU:
			_open_world_map()
		GameState.SETTINGS:
			_open_main_menu()
		GameState.SAVE_SLOTS:
			_open_main_menu()

		GameState.IN_LEVEL:
			pass

func _open_main_menu():

	current_state = GameState.MAIN_MENU

	_set_start_menu_visible(true)
	_set_settings_menu_visible(false)
	_set_slots_menu_visible(false)
	_set_world_map_visible(true)

	world_map.process_mode = Node.PROCESS_MODE_DISABLED

	_pause_world_map(true)

func _open_settings():

	current_state = GameState.SETTINGS

	_set_start_menu_visible(false)
	_set_settings_menu_visible(true)

	world_map.process_mode = Node.PROCESS_MODE_DISABLED

func _open_world_map():

	current_state = GameState.WORLD_MAP

	_set_start_menu_visible(false)
	_set_settings_menu_visible(false)
	_set_slots_menu_visible(false)
	_set_world_map_visible(true)
	_set_score_ui_visible(true)

	world_map.process_mode = Node.PROCESS_MODE_PAUSABLE

	world_map.set_camera_enabled(true)

	_pause_world_map(false)

func _open_save_slots():
	current_state = GameState.SAVE_SLOTS
	_set_start_menu_visible(false)
	_set_slots_menu_visible(true)

	world_map.process_mode = Node.PROCESS_MODE_DISABLED

func _enter_level():

	current_state = GameState.IN_LEVEL

	_set_start_menu_visible(false)
	_set_settings_menu_visible(false)
	_set_score_ui_visible(false)

	world_map.process_mode = Node.PROCESS_MODE_DISABLED

	world_map.set_camera_enabled(false)

	_pause_world_map(false)

func _set_start_menu_visible(sm_is_visible : bool):
	EventBus.world_show_sm.emit(sm_is_visible)

func _set_score_ui_visible(is_visible : bool):
	EventBus.world_hide_score_view.emit(is_visible)

func _set_settings_menu_visible(settings_is_visible : bool):
	EventBus.world_hide_settings_menu.emit(settings_is_visible)

func _set_slots_menu_visible(slots_is_visible : bool):
	if slots_is_visible:
		EventBus.world_update_data.emit()

	EventBus.world_hide_slots_view.emit(slots_is_visible)

func _set_world_map_visible(is_world_map_visible : bool):
	world_map.visible = is_world_map_visible

func _pause_world_map(is_paused : bool):
	get_tree().paused = is_paused

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

		_set_world_map_visible(false)

		_enter_level()

func _unload_level():
	if current_level_instance:
		current_level_instance.queue_free()

func _check_input_controller():
	var joypads = Input.get_connected_joypads()
	if joypads.size() > 0:
		GameManager.is_joypad_connected = true
	else:
		GameManager.is_joypad_connected = false

	# Subscribe to joypad connection
	Input.joy_connection_changed.connect(_on_joypad_connection_changed)

# --------------- Signals -----------------------
func  _on_player_finished():
	_unload_level()
	FadeScreen.fade_out()

func _on_fade_out_finished():
	match pending_transition:

		TransitionAction.RELOAD_LEVEL:
			load_level(current_level_path, GameManager.current_level_id)

		TransitionAction.RETURN_TO_MAP:
			_unload_level()
			_open_world_map()
			FadeScreen.fade_in()

	pending_transition = TransitionAction.NONE

func _on_quit_level_received():
	pending_transition = TransitionAction.RETURN_TO_MAP
	FadeScreen.fade_out()

func _on_restart_level_received():
	pending_transition = TransitionAction.RELOAD_LEVEL
	FadeScreen.fade_out()

func _on_return_to_map_received(level_id : int):
	max_level_reached = GameManager.load_progress(GameManager.current_save_slot)

	if level_id + 1 > max_level_reached:
		max_level_reached += 1
		GameManager.save_progress(max_level_reached)

	pending_transition = TransitionAction.RETURN_TO_MAP
	world_map.unlock_levels(GameManager.current_save_slot)
	world_map.focus_last_played_level()
	FadeScreen.fade_out()

func _on_sm_start_game():
	_open_world_map()

func _on_sm_show_game_slots():
	_open_save_slots()

func _on_sm_settings() -> void:
	_open_settings()

func _on_sm_quit_game() -> void:
	get_tree().quit()

func _on_joypad_connection_changed(_device: int, connected: bool):
	GameManager.is_joypad_connected = connected

func _on_brightness_changed(value : float) -> void:
	brightness_mat.set_shader_parameter("brightness", value)

func _on_slot_pressed(id : int) -> void:
	GameManager.load_progress(id)
	world_map.unlock_levels(id)
	world_map.focus_last_played_level()
	_open_world_map()
