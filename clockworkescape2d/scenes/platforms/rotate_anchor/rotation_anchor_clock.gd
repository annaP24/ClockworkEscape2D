extends Node2D

@export var rotation_deg : float = 90.0
@export var is_clockwise : bool = true
@export var rotation_timeout : float = 2.0
@export var start_delay : float = 0.0
@export var rotation_duration : float = 0.35

@onready var rotation_timer: Timer = $RotationTimer
@onready var start_delay_timer: Timer = $StartDelay

var _is_rotating : bool = false
var _rotation_tween : Tween

func _ready() -> void:
	rotation_timer.one_shot = true
	start_delay_timer.one_shot = true

	if start_delay > 0.0:
		start_delay_timer.wait_time = start_delay
		start_delay_timer.start()
	else:
		rotation_timer.start(rotation_timeout)

func _on_rotation_timer_timeout() -> void:
	if _is_rotating:
		return

	_is_rotating = true

	if _rotation_tween and _rotation_tween.is_valid():
		_rotation_tween.kill()

	var direction := 1.0 if is_clockwise else -1.0
	var target_rotation := snappedf(rotation_degrees + (rotation_deg * direction), 0.001)

	_rotation_tween = create_tween()
	_rotation_tween.tween_property(self, "rotation_degrees", target_rotation, rotation_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_rotation_tween.finished.connect(_on_rotation_step_finished, CONNECT_ONE_SHOT)

func _on_start_delay_timeout() -> void:
	rotation_timer.start(rotation_timeout)

func _on_rotation_step_finished() -> void:
	rotation_degrees = snappedf(rotation_degrees, 0.001)
	_is_rotating = false
	rotation_timer.start(rotation_timeout)
