extends Node

var current_level_path: String = ""
var current_level_id: int = -1
var current_save_slot: int = 1
var current_screen: String = "start_menu"
var is_joypad_connected: bool = false
var mouse_forced_hidden: bool = false
var pending_level_request: Dictionary = {
	"path": "",
	"id": -1,
}

func _ready() -> void:
	_check_input_controller()

func _check_input_controller() -> void:
	var joypads = Input.get_connected_joypads()
	is_joypad_connected = joypads.size() > 0
	update_mouse_visibility(mouse_forced_hidden)

	if not Input.joy_connection_changed.is_connected(_on_joypad_connection_changed):
		Input.joy_connection_changed.connect(_on_joypad_connection_changed)

func _on_joypad_connection_changed(_device: int, connected: bool) -> void:
	is_joypad_connected = connected
	update_mouse_visibility(mouse_forced_hidden)

func update_mouse_visibility(force_hidden: bool = false) -> void:
	mouse_forced_hidden = force_hidden
	if mouse_forced_hidden or is_joypad_connected:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func set_level_request(path_to_level: String, level_id: int) -> void:
	current_level_path = path_to_level
	current_level_id = level_id
	pending_level_request = {
		"path": path_to_level,
		"id": level_id,
	}

func consume_level_request() -> Dictionary:
	var request = pending_level_request.duplicate()
	return request
