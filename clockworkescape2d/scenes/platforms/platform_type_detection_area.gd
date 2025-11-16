extends Area2D

@onready var parent = get_parent()

func get_type():
	return parent.wall_type

func get_is_moving():
	return parent.get_is_moving()
