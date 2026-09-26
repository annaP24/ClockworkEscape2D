extends Node2D

var degrees_per_tick: float = 6.0
var seconds_per_tick: float = 1.0
var is_rotating: bool = false

var _accumulated_time: float = 0.0


func _process(delta: float) -> void:
	if not is_rotating:
		return
	_accumulated_time += delta
	# only advance once a full tick interval has elapsed, keeping the remainder for the next tick
	while _accumulated_time >= seconds_per_tick:
		_accumulated_time -= seconds_per_tick
		rotation += deg_to_rad(degrees_per_tick)


func start_rotating() -> void:
	is_rotating = true


func stop_rotating() -> void:
	is_rotating = false
	_accumulated_time = 0.0
