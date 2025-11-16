@tool
extends StaticBody2D

@export var sway_speed : float = 1.0
@export var max_rotation : float = 45.0
@onready var rotation_marker: Marker2D = $RotationMarker

func _ready() -> void:
	rotation_marker.rotation_degrees = max_rotation
	start_sway()
	#sway_right()

func start_sway():
	 # Create a tween to animate rotation
	var tween = create_tween()
	tween.set_loops() # infinite looping
	#Potential moves
	#tween.set_trans(Tween.TRANS_ELASTIC)
	#tween.set_trans(Tween.TRANS_EXPO)
	#tween.set_trans(Tween.TRANS_SINE)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	# Sequence:left -> right
	tween.tween_property(rotation_marker, "rotation_degrees", -max_rotation, sway_speed)
	tween.tween_property(rotation_marker, "rotation_degrees", max_rotation, sway_speed)

func sway_right():
	var tween = create_tween()
	#tween.set_loops() # infinite looping
	#Potential moves
	#tween.set_trans(Tween.TRANS_ELASTIC)
	#tween.set_trans(Tween.TRANS_EXPO)
	#tween.set_trans(Tween.TRANS_SINE)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	#tween.step_finished.connect()
	# Sequence:left -> right
	tween.tween_property(rotation_marker, "rotation_degrees", -max_rotation, sway_speed)
	tween.finished.connect(_on_tween_r_finished)
	#tween.tween_property(rotation_marker, "rotation_degrees", max_rotation, sway_speed)
	tween.play()
func sway_left():
	var tween = create_tween()
	#tween.set_loops() # infinite looping
	#Potential moves
	#tween.set_trans(Tween.TRANS_ELASTIC)
	#tween.set_trans(Tween.TRANS_EXPO)
	#tween.set_trans(Tween.TRANS_SINE)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_on_tween_l_finished)
	#tween.step_finished.connect()
	# Sequence:left -> right
	#tween.tween_property(rotation_marker, "rotation_degrees", -max_rotation, sway_speed)
	tween.tween_property(rotation_marker, "rotation_degrees", max_rotation, sway_speed)
	tween.play()

func _on_tween_l_finished():
	#await get_tree().create_timer(1.0).timeout
	#print("Slide right")
	sway_right()
func _on_tween_r_finished():
	#await get_tree().create_timer(1.0).timeout
	#print("Slide left")
	sway_left()
