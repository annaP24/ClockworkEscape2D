extends CharacterBody2D
class_name PlayerFSM
signal player_died
signal player_finished

@export var max_speed : float = 4.0 
@export var max_jump_count : int = 2 
@export var jump_height : float = 3.5
@export var jump_gravity : float = 3000.0
@export var fall_gravity : float = 4000.0
#@export var jump_time_to_peak : float = 0.5
#@export var jump_time_to_descent : float = 0.6 #0.4
@export var jump_buffer_timeout : float = 0.3
@export var coyote_timeout : float = 0.1
@export var gravity_coef : float = 5.0
@export var number_of_jumps : int = 2
@export var dash_duration : float = 0.1
@export var dash_timeout : float = 0.5
@export var dash_speed : float = 50.0
@export var move_acc : float = 0.3
@export var move_dec : float = 0.3
var multiplicator_2d : float = 1000.0
@onready var fsm: CompFsmNode = $FSM
#@onready var jump_velocity : float = ((-2.0 * jump_height) / jump_time_to_peak) *  multiplicator_2d
#@onready var jump_gravity : float = ((2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak))* multiplicator_2d
#@onready var fall_gravity : float = ((2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * multiplicator_2d

@onready var animation_player_rotate: AnimationPlayer = $AnimationPlayer
#@onready var anima_player_spawn_die: AnimationPlayer = $gear_with_animation/AnimationPlayer

@onready var jump_buffer_timer: Timer = $JumpBuffer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var ray_cast_timer: Timer = $RayCastTimer
@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_timeout_timer: Timer = $DashTimeoutTimer
@onready var gear: Sprite2D = $CharacterSprite
@onready var gear_with_animation: AnimatedSprite2D = $CharacterAnimated

enum animations {RUN_LEFT, RUN_RIGHT, JUMP, IDLE, DIE, SPAWN}

var gravity : Vector2 = Vector2.ZERO
var jump_buffer : bool = false
var jump_button_released : bool = false
var jump_count : int = 0
var coyote_jump : bool = false
var coyote_jump_timer_started : bool = false
var can_dash : bool = true
var is_dashing : bool = false
var is_movable : bool = false
var coil_push_active : bool = false
var coil_jump_pressed : bool = false
var jump_velocity : float = 0.0

func _ready() -> void: 
	jump_count = max_jump_count	

	gravity = Vector2(0,fall_gravity)# * multiplicator_2d
	update_animation(animations.SPAWN)
	
func _process(delta: float) -> void:
	jump_velocity = -(sqrt(2*jump_gravity*jump_height))
	apply_gravity(delta)
	move_and_slide()
	
	Debug.print_value("JumpCounter", jump_count)	
	
func apply_gravity(delta):
	velocity += gravity * delta
	
func get_player_gravity():
	if velocity.y < 0.0:
		gravity = Vector2(gravity.x, jump_gravity)
	else:
		gravity = Vector2(gravity.x, fall_gravity)
		
	return gravity	
	
func move_player_x(directionX : int, speed : float = max_speed):
	if directionX != 0:
		velocity.x = speed * directionX # move_toward(velocity.x, speed * directionX, move_acc) 
	else:
		velocity.x = 0 #move_toward(velocity.x, 0, move_dec) 
		
func move_player_y(directionY : int,  speed : float = max_speed):
	velocity.y = speed * directionY
	
func update_animation(new_animation : animations):
	match new_animation:
		animations.RUN_LEFT: 
			animation_player_rotate.play("rotate_left")
		animations.RUN_RIGHT: 
			animation_player_rotate.play("rotate_right")
		animations.IDLE:
			animation_player_rotate.stop()
		animations.DIE:
			is_movable = false
			gear_with_animation.visible = true
			gear.visible = false
			#anima_player_spawn_die.speed_scale = 3
			#anima_player_spawn_die.play("dead")
			#await anima_player_spawn_die.animation_finished
			player_died.emit()
		animations.SPAWN:
			#anima_player_spawn_die.speed_scale = 1
			#anima_player_spawn_die.play("appear")
			#await anima_player_spawn_die.animation_finished
			#anima_player_spawn_die.play("spawn")
			#await anima_player_spawn_die.animation_finished
			#gear.visible = true
			#gear_with_animation.visible = false
			is_movable = true
#------------------------RayCast management -----------------------------
func rc_left() -> bool:
	return $Raycasts/RayCastLeft.is_colliding() or $Raycasts/RayCastLeft2.is_colliding()
func rc_right() -> bool:
	return $Raycasts/RayCastRight.is_colliding() or $Raycasts/RayCastRight2.is_colliding()
func rc_up() -> bool:
	return $Raycasts/RayCastUp.is_colliding() or $Raycasts/RayCastUp2.is_colliding()
	
func get_collider_left():
	if  $Raycasts/RayCastLeft.is_colliding():
		return  $Raycasts/RayCastLeft.get_collider()
	elif $Raycasts/RayCastLeft2.is_colliding():
		return $Raycasts/RayCastLeft2.get_collider()
		
func get_collider_right():
	if  $Raycasts/RayCastRight.is_colliding():
		return  $Raycasts/RayCastRight.get_collider()
	elif $Raycasts/RayCastRight2.is_colliding():
		return $Raycasts/RayCastRight2.get_collider()
		
func get_collider_up():
	if  $Raycasts/RayCastUp.is_colliding():
		return  $Raycasts/RayCastUp.get_collider()
	elif $Raycasts/RayCastUp2.is_colliding():
		return $Raycasts/RayCastUp2.get_collider()
		
func switch_ray_casts_on():	
	for rc in get_node("Raycasts").get_children():
		rc.enabled = true

func switch_rc_up_off():	
	$Raycasts/RayCastUp.enabled = false
	$Raycasts/RayCastUp2.enabled = false
	ray_cast_timer.start()
func switch_rc_left_off():	
	$Raycasts/RayCastLeft.enabled = false
	$Raycasts/RayCastLeft2.enabled = false
	ray_cast_timer.start()
	
func switch_rc_right_off():
	$Raycasts/RayCastRight.enabled = false
	$Raycasts/RayCastRight2.enabled = false
	ray_cast_timer.start()

func _on_ray_cast_timer_timeout() -> void:
	switch_ray_casts_on()

func _on_jump_buffer_timeout() -> void:
	Debug.print_value("JumpBufferTimerStarted", false)
	jump_buffer = false

func _on_coyote_timer_timeout() -> void:
	coyote_jump = false

func _on_dash_duration_timer_timeout() -> void:
	is_dashing = false

func _on_dash_timeout_timer_timeout() -> void:
	can_dash = true


func _on_comp_2d_hurtbox_hurt(damage: Variant) -> void:
	update_animation(animations.DIE)
