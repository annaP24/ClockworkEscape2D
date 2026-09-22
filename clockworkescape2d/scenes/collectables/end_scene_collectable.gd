extends Node2D
class_name EndSceneCollectable

enum Direction { LEFT, RIGHT}
@export var rotation_dir: Direction
@export var rotation_speed: float = 0.5
func set_rotation_direction(direction: Direction):
	rotation_dir = direction

func _process(delta):
	_rotate(delta)

func _rotate(delta):
	if rotation_dir == Direction.LEFT:
		rotation -= delta * rotation_speed
	elif rotation_dir == Direction.RIGHT:
		rotation += delta * rotation_speed