extends Node2D

@export var rotion_speed : float = 70.0
@export var is_clockwise : bool = true

var time : float = 0.0

func _physics_process(delta: float) -> void:
	time += delta
	if is_clockwise:
		rotation_degrees = time * rotion_speed
	else:
		rotation_degrees = time * rotion_speed
