extends Node2D
class_name WorldMap

const LEVELS_PER_PAGE := 4
const TOTAL_PAGES := 5
const TOTAL_LEVELS := 20

@onready var levels_root: Node2D = %Levels
@onready var left_button: TextureButton = %ButtonLeft
@onready var right_button: TextureButton = %ButtonRight

var current_focused_level: Node = null
var is_joypad_connected := false
var current_page := 0
var all_levels: Array = []

func _ready() -> void:
	_collect_levels()
	_connect_nav_buttons()
	unlock_levels()
	focus_last_played_level()
	_update_page_buttons()
	_apply_page()

func _show_navigation() -> void:
	visible = true
	set_process_input(true)
	set_process_unhandled_input(true)
	if levels_root:
		levels_root.visible = true

func _collect_levels() -> void:
	all_levels.clear()
	for child in levels_root.get_children():
		if child.has_method("trigger_button") and child.get("level_id") != null:
			all_levels.append(child)

func _connect_nav_buttons() -> void:
	if is_instance_valid(left_button):
		left_button.pressed.connect(_on_previous_page_pressed)
	if is_instance_valid(right_button):
		right_button.pressed.connect(_on_next_page_pressed)

func _on_previous_page_pressed() -> void:
	if !visible:
		return
	_change_page(-1)

func _on_next_page_pressed() -> void:
	if !visible:
		return
	_change_page(1)

func _change_page(offset: int) -> void:
	if !visible:
		return
	current_page = clamp(current_page + offset, 0, TOTAL_PAGES - 1)
	_apply_page()
	_update_page_buttons()

func _apply_page() -> void:
	var max_level_unlocked: int = GameSaveManager.load_progress()
	var page_start_index := current_page * LEVELS_PER_PAGE + 1
	var slot_index := 0
	for level in all_levels:
		var actual_level_id := page_start_index + slot_index
		var is_in_page := actual_level_id <= TOTAL_LEVELS
		level.visible = is_in_page
		if !is_in_page:
			level.set_highlight(false)
			if current_focused_level == level:
				current_focused_level = null
			level.is_unlocked = false
			level.update_visual()
			slot_index += 1
			continue
		level.level_id = actual_level_id
		level.parent = self
		level.is_unlocked = actual_level_id <= max_level_unlocked
		if !level.level_selected.is_connected(_on_level_selected):
			level.level_selected.connect(_on_level_selected)
		level.update_visual()
		slot_index += 1

func _update_page_buttons() -> void:
	left_button.visible = current_page > 0
	right_button.visible = current_page < TOTAL_PAGES - 1

func unlock_levels() -> void:
	_apply_page()

func focus_last_played_level() -> void:
	var last_unlocked: Node = null
	for level in all_levels:
		if level.visible and level.is_unlocked:
			last_unlocked = level
	if last_unlocked == null:
		return
	current_focused_level = last_unlocked
	#current_focused_level.set_highlight(true)
	#_move_to_page_for_level(last_unlocked)

func set_joypad_connected(connected: bool) -> void:
	is_joypad_connected = connected

func set_camera_enabled(enabled: bool) -> void:
	if has_node("Camera2D"):
		var camera: Camera2D = $Camera2D
		camera.enabled = enabled
		camera.set_process(enabled)
		camera.set_physics_process(enabled)
		camera.set_process_input(enabled)
		camera.set_process_unhandled_input(enabled)

func _unhandled_input(event: InputEvent) -> void:
	if !visible:
		return
	if get_tree().paused:
		return
	if event.is_action_pressed("select_level") and current_focused_level != null:
		current_focused_level.trigger_button()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_left"):
		_change_page(-1)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_right"):
		_change_page(1)
		get_viewport().set_input_as_handled()
		return
	if current_focused_level == null:
		return
	var next_node: Node = null
	if event.is_action_pressed("level_up"):
		next_node = current_focused_level.neighbour_up
	elif event.is_action_pressed("level_down"):
		next_node = current_focused_level.neighbour_down
	if next_node:
		_change_focus(next_node, true)
		get_viewport().set_input_as_handled()

func _change_focus(level: Node, is_joypad_selection: bool) -> void:
	if !level.is_unlocked:
		return
	if current_focused_level:
		current_focused_level.set_highlight(false)
	current_focused_level = level
	current_focused_level.set_highlight(true)
	_move_to_page_for_level(level)
	if (
		(is_joypad_connected and is_joypad_selection)
		or Input.is_action_pressed("level_down")
		or Input.is_action_pressed("level_up")
	):
		pass

func _move_to_page_for_level(level) -> void:
	if level == null:
		return
	var level_page_index := int(floor((level.level_id - 1) / LEVELS_PER_PAGE))
	if level_page_index != current_page:
		current_page = level_page_index
		_apply_page()
		_update_page_buttons()

func _on_level_selected(level_id: int) -> void:
	if level_id < 1 or level_id > TOTAL_LEVELS:
		return
	_hide_navigation()
	GameSaveManager.current_level = level_id - 1
	GameSaveManager.current_level_id = level_id
	GameSaveManager.set_level_paths()
	var target_path := GameSaveManager.get_level_path()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if target_path == "":
		push_error("No level path found for level %d" % level_id)
		return
	get_parent().load_level(target_path, level_id)

func _hide_navigation() -> void:
	visible = false
	levels_root.visible = false
	if is_instance_valid(left_button):
		left_button.visible = false
		left_button.disabled = true
		left_button.set_process_input(false)
		left_button.set_process_unhandled_input(false)
	if is_instance_valid(right_button):
		right_button.visible = false
		right_button.disabled = true
		right_button.set_process_input(false)
		right_button.set_process_unhandled_input(false)
	set_process_input(false)
	set_process_unhandled_input(false)

func hide_level_buttons(is_hidden: bool)-> void:
	levels_root.visible = not is_hidden
	if is_instance_valid(left_button):
		left_button.visible = not is_hidden
		left_button.disabled = is_hidden
	if is_instance_valid(right_button):
		right_button.visible = not is_hidden
		right_button.disabled = is_hidden
