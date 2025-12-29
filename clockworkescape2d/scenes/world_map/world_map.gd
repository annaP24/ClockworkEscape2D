extends Node2D
#signal load_level(level_path)
@onready var line_2d: Line2D = $PathContainer/Line2D
@onready var levels_container: Node2D = $LevelsContainer
@onready var parent = get_parent()
@onready var camera_2d: Camera2D = $Camera2D

const COEF = 0.3
var current_level_instance : Level = null
var current_level_index : int = 0
var current_level_path : String = ""
var curve : Curve2D = Curve2D.new()
var is_level_manager_visible : bool = true

func _ready():
	#Get Worl node
	parent = get_parent()
	_generate_curve()
	unlock_levels()

func unlock_levels():
	for node in levels_container.get_children():
		if node.level_id <= parent.max_level_reached:
			node.is_unlocked = true
		else:
			node.is_unlocked = false
		node.update_visual()
		if !node.is_connected("level_selected", _on_level_selected):
			node.level_selected.connect(_on_level_selected)

# -------------------- Visuals ---------------------------------------------------#
func _calc_tangent_in(point_before : Vector2, point_after : Vector2, current_point : Vector2):
	var tangent = (point_before - point_after).normalized()
	#var distance = abs(current_point - point_after)
	var distance = current_point.distance_to(point_before)
	return tangent * (distance * COEF)

func _calc_tangent_out(point_before : Vector2, point_after : Vector2, current_point : Vector2):
	var tangent = (point_before - point_after).normalized()
	#var distance = abs(current_point - point_before)
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
	line_2d.texture = preload("res://scenes/world_map/assets/road.png")

# ---------------------- SIgnals -----------------------------------------------
func _on_level_selected(level_id):
	# Start level scene:
	GameManager.current_level = level_id - 1
	parent.load_level("res://scenes/levels/scenes/level_%s.tscn" % level_id)
