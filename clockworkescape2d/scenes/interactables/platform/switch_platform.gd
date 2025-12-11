extends AnimatableBody2D
@export var switch_1: Switch
@export var switch_2: Switch
@export var is_move_vertical : bool = true
@export var is_move_up : bool = false
@export var is_move_right : bool = false
@onready var move_delay_timer: Timer = $MoveDelayTimer

var wait_timeout : float = 0.3
var max_move_offset : float = 200.0
var move_delta : float = 2.0
var init_position : Vector2 = Vector2.ZERO
var is_switch_active : bool = false
var is_switch_not_active : bool = false
var is_destination_reached : bool = false

func _ready() -> void:
	move_delay_timer.wait_time = wait_timeout
	init_position = global_position
	switch_1.is_active.connect(_on_switch_is_active)
	switch_1.is_not_active.connect(_on_switch_is_not_active)
	if switch_2:
		switch_2.is_active.connect(_on_switch_is_active)
		switch_2.is_not_active.connect(_on_switch_is_not_active)

func _process(_delta: float) -> void:
	if is_switch_active:
		move()
	elif is_switch_not_active:
		revert_movement()

func move():
	if is_move_vertical:
		if is_move_up:
			move_up()
		else:
			move_down()
	elif !is_move_vertical:
		if is_move_right:
			move_right()
		else:
			move_left()

func revert_movement():
	if is_move_vertical:
		if is_move_up:
			move_down()
		else:
			move_up()
	else:
		if is_move_right:
			move_left()
		else:
			move_right()

func move_up():
	var move_offset : float = 0.0
	if is_move_up:
		move_offset = max_move_offset
	if global_position.y < init_position.y - move_offset:
		is_destination_reached = true
		return
	global_position.y = global_position.y - move_delta

func move_down():
	var move_offset : float = 0.0
	if !is_move_up:
		move_offset = max_move_offset
	if global_position.y > init_position.y + move_offset:
		is_destination_reached = true
		return

	global_position.y = global_position.y + move_delta

func move_left():
	var move_offset : float = 0.0
	if !is_move_right:
		move_offset = max_move_offset
	if global_position.x < init_position.x - move_offset:
		is_destination_reached = true
		return
	global_position.x = global_position.x - move_delta

func move_right():
	var move_offset : float = 0.0
	if is_move_right:
		move_offset = max_move_offset
	if global_position.x > init_position.x + move_offset:
		is_destination_reached = true
		return
	global_position.x = global_position.x + move_delta

func _on_switch_is_active():
	is_switch_active = true
	is_switch_not_active = false
	is_destination_reached = false

func _on_switch_is_not_active():
	move_delay_timer.start()

func _on_move_delay_timer_timeout() -> void:
	is_switch_active = false
	is_switch_not_active = true
