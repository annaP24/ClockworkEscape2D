extends StaticBody2D

@export var sway_speed : float = 0.5
@export var max_rotation : float = 45.0
@onready var rotation_marker: Marker2D = $RotationMarker

var isRight : bool = true

func _process(_delta: float) -> void:
	if isRight:
		rotation_marker.rotation_degrees -= sway_speed
		if abs(max_rotation + rotation_marker.rotation_degrees) <= 0.5:
			isRight = false
	else:
		rotation_marker.rotation_degrees += sway_speed
		if abs(max_rotation - rotation_marker.rotation_degrees) < 0.5:
			isRight = true
