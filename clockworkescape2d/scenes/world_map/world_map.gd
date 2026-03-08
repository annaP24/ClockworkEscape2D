extends Node2D
class_name WorldMap

@onready var line_2d: Line2D = $PathContainer/Line2D
@onready var levels_container: Node2D = $LevelsContainer
@onready var parent = get_parent()
@onready var camera_2d: Camera2D = $Camera2D

const COEF = 0.3
var current_level_instance : Level = null
var current_level_index : int = 0
var current_level_path : String = ""
var curve : Curve2D = Curve2D.new()
var current_focused_level : LevelNode
var is_joypad_connected : bool = false

func _ready():
	# Get Worl node
	parent = get_parent()
	_generate_curve()
	unlock_levels()
	current_focused_level = levels_container.get_children()[0]
	current_focused_level.set_highlight(true)

func _unhandled_input(event: InputEvent) -> void:
	if visible:
		if current_focused_level == null:
			return
		# Handle button - confirm press
		if event.is_action_pressed("select_level"):
			current_focused_level.trigger_button()
			get_viewport().set_input_as_handled()
			return
		var next_node : LevelNode = null
		# Handle joystic movement (level selection)
		if event.is_action_pressed("level_up"):
			next_node = current_focused_level.neighbour_up
		elif event.is_action_pressed("level_down"):
			next_node = current_focused_level.neighbour_down
		if next_node:
			_change_focus(next_node, true)
			get_viewport().set_input_as_handled()

func unlock_levels():
	var node_cnt : int = 0
	var levels : Array = levels_container.get_children() as Array[LevelNode]
	var nr_of_levels = levels.size()
	for node in levels:
		node.parent = self
		# Set neighbouring nodes for selection
		if node_cnt == 0:
			node.neighbour_up = levels[node_cnt + 1]
		elif node_cnt == nr_of_levels - 1:
			node.neighbour_down = levels[node_cnt - 1]
		else:
			node.neighbour_up = levels[node_cnt + 1]
			node.neighbour_down = levels[node_cnt - 1]

		if node.level_id <= parent.max_level_reached:
			node.is_unlocked = true
		else:
			node.is_unlocked = false
		node.update_visual()
		if !node.is_connected("level_selected", _on_level_selected):
			node.level_selected.connect(_on_level_selected)
		node_cnt += 1

func set_joypad_connected(joypad_connected : bool):
	is_joypad_connected = joypad_connected
# -------------------- Visuals ---------------------------------------------------#
func _calc_tangent_in(point_before : Vector2, point_after : Vector2, current_point : Vector2):
	var tangent = (point_before - point_after).normalized()
	var distance = current_point.distance_to(point_before)
	return tangent * (distance * COEF)

func _calc_tangent_out(point_before : Vector2, point_after : Vector2, current_point : Vector2):
	var tangent = (point_before - point_after).normalized()
	var distance = current_point.distance_to(point_after)
	return -tangent * (distance * COEF)

func _generate_curve():
	var points = []
	for level in levels_container.get_children():
		points.append(level.global_position)
	# Add points first
	for p in points:
		curve.add_point(p)

	for i in points.size()-1:
		if i == 0 or i == points.size():
			pass
		else:
			curve.set_point_in(i, _calc_tangent_in(points[i-1], points[i+1], points[i]))
			curve.set_point_out(i, _calc_tangent_out(points[i-1], points[i+1], points[i]))
	curve.set_bake_interval(20)
	line_2d.points = curve.get_baked_points()
	line_2d.width = 240
	line_2d.texture = preload("res://scenes/world_map/assets/road2.png")

func _change_focus(level : LevelNode, is_joypad_selection : bool):
	if current_focused_level:
		current_focused_level.set_highlight(false)
	if level.is_unlocked:
		current_focused_level = level
		current_focused_level.set_highlight(true)
	if (is_joypad_connected and is_joypad_selection) or (Input.is_action_just_pressed("level_down") or \
	Input.is_action_just_pressed("level_up")):
		camera_2d.move_camera_with_selection(current_focused_level.position)
# ---------------------- Signals -----------------------------------------------
func _on_level_selected(level_id):
	# Start level scene:
	GameManager.current_level = level_id - 1
	GameManager.level_id = level_id
	parent.load_level(GameManager.get_level_path(), level_id)
