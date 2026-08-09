extends Node2D

@export var rotion_speed : float = 70.0
@export var is_clockwise : bool = true
@export var start_delay : float = 0.0
@onready var timer: Timer = $Timer

var time : float = 0.0
var is_rotating : bool = false

func _ready() -> void:
	if start_delay > 0.0:
		timer.start(start_delay)
	else:
		is_rotating = true

func _physics_process(delta: float) -> void:
	time += delta
	if is_clockwise:
		rotation_degrees = time * rotion_speed
	else:
		rotation_degrees = -time * rotion_speed


func _on_timer_timeout() -> void:
	is_rotating = true
