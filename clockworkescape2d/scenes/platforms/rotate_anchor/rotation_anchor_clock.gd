extends Node2D

@export var rotation_deg : float = 90.0
@export var is_clockwise : bool = true
@export var rotation_timeout : float = 2.0

@onready var rotation_timer: Timer = $RotationTimer

var time : float = 0.0
func _ready() -> void:
	rotation_timer.start(rotation_timeout)

func _on_rotation_timer_timeout() -> void:
	var tween = get_parent().create_tween()
	tween.tween_property(self, "rotation_degrees", rotation_degrees - 5.0, 0.3).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", rotation_degrees + rotation_deg, 0.5)#.set_ease(Tween.EASE_IN_OUT)
	tween.play()
	#rotation_degrees += rotation_degree
	#if rotation_degrees == 360:
		#rotation_degrees = 0
