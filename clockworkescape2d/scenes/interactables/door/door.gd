extends StaticBody2D
@export var switch_1: Switch
@export var switch_2: Switch
@export var wait_timeout : float = 0.3
@export var move_up_speed : float = 200.0
@export var move_down_speed : float = 100.0
@onready var sprites: Node2D = $Sprites
@onready var move_delay_timer: Timer = $MoveDelayTimer
@onready var sparks: GPUParticles2D = $Sparks

var is_move_up : bool = true
var max_move_offset : float = 2 * 64.0
var init_position : Vector2 = Vector2.ZERO
var target_position : Vector2 = Vector2.ZERO
var current_target : Vector2 = Vector2.ZERO
var move_speed : float = 0.0

func _ready() -> void:
	move_delay_timer.wait_time = wait_timeout
	init_position = global_position
	move_speed = move_up_speed
	sparks.emitting = false
	var offset : Vector2 = Vector2.ZERO

	if is_move_up:
		offset = Vector2(0, max_move_offset * -1)
	else:
		offset = Vector2(0, max_move_offset * 1)

	target_position = init_position + offset
	current_target = init_position

	switch_1.is_active.connect(_on_switch_is_active)
	switch_1.is_not_active.connect(_on_switch_is_not_active)
	if switch_2:
		switch_2.is_active.connect(_on_switch_is_active)
		switch_2.is_not_active.connect(_on_switch_is_not_active)

func _physics_process(delta: float) -> void:
	sprites.global_position = sprites.global_position.move_toward(current_target, move_speed * delta)
	if sprites.global_position == target_position:
		sparks.emitting = false
func _on_switch_is_active():
	move_delay_timer.stop() # Cancel timers
	current_target = target_position
	sparks.emitting = true

func _on_switch_is_not_active():
	move_delay_timer.start()
	sparks.emitting = false

func _on_move_delay_timer_timeout() -> void:
	if switch_2:
		move_speed = move_down_speed
		current_target = init_position
