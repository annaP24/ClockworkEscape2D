@tool
extends StaticBody2D

@export var sway_speed : float = 1.0
@export var max_rotation : float = 45.0
@onready var rotation_marker: Marker2D = $RotationMarker

func _ready() -> void:
	rotation_marker.rotation_degrees = max_rotation
	start_sway()

func start_sway():
	 # Create a tween to animate rotation
	var tween = create_tween()
	tween.set_loops() # infinite looping

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	# Sequence:left -> right
	tween.tween_property(rotation_marker, "rotation_degrees", -max_rotation, sway_speed)
	tween.tween_property(rotation_marker, "rotation_degrees", max_rotation, sway_speed)

func sway_right():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	# Sequence:left -> right
	tween.tween_property(rotation_marker, "rotation_degrees", -max_rotation, sway_speed)
	tween.finished.connect(_on_tween_r_finished)
	#tween.tween_property(rotation_marker, "rotation_degrees", max_rotation, sway_speed)
	tween.play()
func sway_left():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_on_tween_l_finished)
	# Sequence:left -> right
	tween.tween_property(rotation_marker, "rotation_degrees", max_rotation, sway_speed)
	tween.play()

func _on_tween_l_finished():
	sway_right()
func _on_tween_r_finished():
	sway_left()
