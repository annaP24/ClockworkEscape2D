extends Area2D
class_name PlatformDetectionArea
@onready var parent = get_parent()

func get_type():
	return parent.wall_type

func get_is_moving():
	return parent.get_is_moving()

func is_platform_detection_area():
	return true
