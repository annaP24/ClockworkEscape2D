extends Node2D

enum RotationDirection { COUNTERCLOCKWISE = -1, CLOCKWISE = 1 }

@export var rotation_speed: float = 45.0

var is_rotating: bool = false
var rotation_direction: RotationDirection = RotationDirection.CLOCKWISE

func _process(delta: float) -> void:
	if is_rotating:
		rotation_degrees += rotation_speed * rotation_direction * delta

func start_rotation(direction: RotationDirection) -> void:
	rotation_direction = direction
	is_rotating = true

func stop_rotation() -> void:
	is_rotating = false
