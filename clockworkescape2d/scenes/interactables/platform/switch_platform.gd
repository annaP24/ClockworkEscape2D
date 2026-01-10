extends AnimatableBody2D
@export var switch_1: Switch
@export var switch_2: Switch
@export var is_move_vertical : bool = true
@export var is_move_up : bool = false
@export var is_move_right : bool = false
@onready var move_delay_timer: Timer = $MoveDelayTimer

var wait_timeout : float = 0.3
var max_move_offset : float = 200.0
var init_position : Vector2 = Vector2.ZERO
var target_position : Vector2 = Vector2.ZERO
var current_target : Vector2 = Vector2.ZERO
var move_speed : float = 100.0

func _ready() -> void:
	move_delay_timer.wait_time = wait_timeout
	init_position = global_position
	var offset : Vector2 = Vector2.ZERO

	if is_move_up and is_move_vertical:
		offset = Vector2(0, max_move_offset * -1)
	elif !is_move_up and is_move_vertical:
		offset = Vector2(0, max_move_offset * 1)
	elif is_move_right and !is_move_vertical:
		offset = Vector2(max_move_offset * 1, 0)
	elif !is_move_right and !is_move_vertical:
		offset = Vector2(max_move_offset * -1, 0)

	target_position = init_position + offset
	current_target = init_position

	switch_1.is_active.connect(_on_switch_is_active)
	switch_1.is_not_active.connect(_on_switch_is_not_active)
	if switch_2:
		switch_2.is_active.connect(_on_switch_is_active)
		switch_2.is_not_active.connect(_on_switch_is_not_active)

func _physics_process(delta: float) -> void:
	global_position = global_position.move_toward(current_target, move_speed * delta)

func _on_switch_is_active():
	move_delay_timer.stop() # Cancel timers
	current_target = target_position

func _on_switch_is_not_active():
	move_delay_timer.start()

func _on_move_delay_timer_timeout() -> void:
	current_target = init_position
