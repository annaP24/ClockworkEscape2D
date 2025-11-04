@tool
extends StaticBody2D

@export var sway_speed : float = 1.5
@export var max_rotation : float = 15.0
@onready var rotation_marker: Marker2D = $RotationMarker

func _ready() -> void:
	rotation_marker.rotation_degrees = max_rotation
	start_sway()

func start_sway():
	 # Create a tween to animate rotation
	var tween = create_tween()
	tween.set_loops() # infinite looping
	#Potential moves
	#tween.set_trans(Tween.TRANS_ELASTIC)
	#tween.set_trans(Tween.TRANS_EXPO)
	#tween.set_trans(Tween.TRANS_SINE)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Sequence:left -> right 
	tween.tween_property(rotation_marker, "rotation_degrees", -max_rotation, sway_speed)
	tween.tween_property(rotation_marker, "rotation_degrees", max_rotation, sway_speed)
#Alternative without tween
#func _process(_delta):
	#var t = Time.get_ticks_msec() / 1000.0
	#rotation_marker.rotation_degrees = sin(t * PI / sway_speed) * max_rotation
