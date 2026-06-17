# Refactored `WorldMap.gd`

extends Node2D
class_name WorldMap

@onready var line_2d: Line2D = $PathContainer/Line2D
@onready var levels_container: Node2D = $LevelsContainer
@onready var camera_controller = $Camera2D

const CURVE_TANGENT_COEF := 0.3

var curve := Curve2D.new()
var current_focused_level : LevelNode
var is_joypad_connected := false


func _ready() -> void:
	_generate_curve()

func _unhandled_input(event: InputEvent) -> void:

	if !visible:
		return

	if get_tree().paused:
		return

	if current_focused_level == null:
		return

	# Confirm selection
	if event.is_action_pressed("select_level"):
		current_focused_level.trigger_button()
		get_viewport().set_input_as_handled()
		return

	var next_node : LevelNode = null

	# Navigation
	if event.is_action_pressed("level_up"):
		next_node = current_focused_level.neighbour_up

	elif event.is_action_pressed("level_down"):
		next_node = current_focused_level.neighbour_down

	if next_node:
		_change_focus(next_node, true)
		get_viewport().set_input_as_handled()


# -----------------------------------------------------------------------------
# Level Setup
# -----------------------------------------------------------------------------

func unlock_levels(id : int) -> void:

	var levels : Array = levels_container.get_children() as Array[LevelNode]
	var level_count := levels.size()
	var max_level_unlocked : int = GameManager.load_progress(id)
	for i in range(level_count):

		var node : LevelNode = levels[i]

		node.parent = self

		# Set neighbours
		if i < level_count - 1:
			node.neighbour_up = levels[i + 1]

		if i > 0:
			node.neighbour_down = levels[i - 1]

		# Unlock state
		if node.level_id <= max_level_unlocked:
			node.is_unlocked = true
		else:
			node.is_unlocked = false

		node.update_visual()

		if !node.level_selected.is_connected(_on_level_selected):
			node.level_selected.connect(_on_level_selected)


func focus_last_played_level() -> void:

	var levels : Array = levels_container.get_children() as Array[LevelNode]
	for level_id in range(levels.size()-1, -1, -1):
		var level = levels[level_id]
		if level.is_unlocked:
			current_focused_level = level
			current_focused_level.set_highlight(true)
			return


func set_joypad_connected(connected : bool) -> void:
	is_joypad_connected = connected


# -----------------------------------------------------------------------------
# Camera
# -----------------------------------------------------------------------------

func set_camera_enabled(enabled : bool) -> void:

	camera_controller.enabled = enabled

	camera_controller.set_process(enabled)
	camera_controller.set_physics_process(enabled)
	camera_controller.set_process_input(enabled)
	camera_controller.set_process_unhandled_input(enabled)

	if !enabled:
		camera_controller.stop_drag()


# -----------------------------------------------------------------------------
# Curve Generation
# -----------------------------------------------------------------------------

func _calc_tangent_in(point_before : Vector2, point_after : Vector2, current_point : Vector2) -> Vector2:

	var tangent = (point_before - point_after).normalized()
	var distance = current_point.distance_to(point_before)

	return tangent * (distance * CURVE_TANGENT_COEF)


func _calc_tangent_out(point_before : Vector2, point_after : Vector2, current_point : Vector2) -> Vector2:

	var tangent = (point_before - point_after).normalized()
	var distance = current_point.distance_to(point_after)

	return -tangent * (distance * CURVE_TANGENT_COEF)


func _generate_curve() -> void:

	curve.clear_points()

	var points : Array[Vector2] = []

	for level in levels_container.get_children():
		points.append(level.global_position)

	# Add points
	for point in points:
		curve.add_point(point)

	# Generate tangents
	for i in range(1, points.size() - 1):

		curve.set_point_in(
			i,
			_calc_tangent_in(points[i - 1], points[i + 1], points[i])
		)

		curve.set_point_out(
			i,
			_calc_tangent_out(points[i - 1], points[i + 1], points[i])
		)

	curve.set_bake_interval(20)

	line_2d.points = curve.get_baked_points()
	line_2d.width = 240
	line_2d.texture = preload("res://scenes/world_map/assets/road.png")


# -----------------------------------------------------------------------------
# Focus Handling
# -----------------------------------------------------------------------------

func _change_focus(level : LevelNode, is_joypad_selection : bool) -> void:

	if !level.is_unlocked:
		return

	if current_focused_level:
		current_focused_level.set_highlight(false)

	current_focused_level = level
	current_focused_level.set_highlight(true)

	if (
		(is_joypad_connected and is_joypad_selection)
		or Input.is_action_pressed("level_down")
		or Input.is_action_pressed("level_up")
	):
		camera_controller.move_camera_with_selection(
			current_focused_level.position
		)


# -----------------------------------------------------------------------------
# Signals
# -----------------------------------------------------------------------------

func _on_level_selected(level_id : int) -> void:

	GameManager.current_level = level_id - 1
	GameManager.current_level_id = level_id

	get_parent().load_level(
		GameManager.get_level_path(),
		level_id
	)
