extends CharacterBody2D
class_name PlayerFSM

signal player_died

@export var max_speed : float = 300.0
@export var max_jump_count : int = 1 
@export var jump_height : float = 192 # 3*64px
@export var jump_gravity : float = 2000.0
@export var fall_gravity : float = 3600.0
@export var jump_buffer_timeout : float = 0.3
@export var coyote_timeout : float = 0.1
@export var gravity_coef : float = 0.75
@export var move_acc : float = 50.0
@export var move_dec : float = 100.0
@export var wall_jump_count_max : int = 1

@onready var fsm: CompFsmNode = $FSM
@onready var animation_player_rotate: AnimationPlayer = $AnimationPlayer
@onready var jump_buffer_timer: Timer = $JumpBuffer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var gear_with_animation: AnimatedSprite2D = $CharacterAnimated
@onready var shape_cast_2d: ShapeCast2D = $ShapeCast2D
@onready var line_2d: Line2D = $Line2D

enum animations {RUN_LEFT, RUN_RIGHT, JUMP, IDLE, DIE, SPAWN}

var gravity : Vector2 = Vector2.ZERO  
var jump_buffer : bool = false
var jump_button_released : bool = false
var jump_count : int = 0
var coyote_jump : bool = false
var coyote_jump_timer_started : bool = false
var is_movable : bool = false
var coil_push_active : bool = false
var coil_jump_pressed : bool = false
var jump_velocity : float = 0.0
var player_died_received : bool = false
var wall_jump_count : int 
var can_grab : bool = true

func _ready() -> void: 
	jump_count = max_jump_count	
	player_died_received= false
	wall_jump_count = wall_jump_count_max
	gravity = Vector2(0, fall_gravity)
	update_animation(animations.SPAWN)
	fsm.start()
	
func _process(delta: float) -> void:
	jump_velocity = -(sqrt(2 * jump_gravity * jump_height))
	apply_gravity(delta)
	if is_movable:
		move_and_slide()
	if rc_not_colliding():
		set_can_grab(true)
	Debug.print_value("CanGrab: ", can_grab)
		
func apply_gravity(delta):
	velocity += gravity * delta

func move_player_x(directionX : int, speed : float = max_speed):
	if directionX != 0:
		velocity.x = move_toward(velocity.x, speed * directionX, move_acc)  #speed * directionX 
	else:
		velocity.x = move_toward(velocity.x, 0, move_dec) 
		
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
			animation_player_rotate.stop()
			player_died_received = true
			gear_with_animation.play("break")
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
	return $Raycasts/RayCastLeft.is_colliding()
func rc_right() -> bool:
	return $Raycasts/RayCastRight.is_colliding()
func rc_up() -> bool:
	return $Raycasts/RayCastUp.is_colliding()
func rc_down() -> bool:
	return $Raycasts/RayCastDown.is_colliding()

func rc_not_colliding():
	return !rc_right() and !rc_left() and !rc_up() and !rc_down()
func rc_any_colliding():
	return rc_right() or !rc_left() or rc_up() or !rc_down()
		
func get_collider_left():
	if $Raycasts/RayCastLeft.is_colliding():
		return  $Raycasts/RayCastLeft.get_collider()
		
func get_collider_right():
	if  $Raycasts/RayCastRight.is_colliding():
		return  $Raycasts/RayCastRight.get_collider()
		
func get_collider_up():
	if  $Raycasts/RayCastUp.is_colliding():
		return  $Raycasts/RayCastUp.get_collider()
		
func get_collider_down():
	if  $Raycasts/RayCastDown.is_colliding():
		return  $Raycasts/RayCastDown.get_collider()

func switch_ray_casts_on():	
	for rc in get_node("Raycasts").get_children():
		rc.enabled = true
		
func switch_ray_casts_off():	
	for rc in get_node("Raycasts").get_children():
		rc.enabled = false

func set_can_grab(grab : bool):
	can_grab = grab
	
func get_can_grab() -> bool:
	return can_grab	
	
func switch_rc_up_off():	
	$Raycasts/RayCastUp.enabled = false

func switch_rc_left_off():	
	$Raycasts/RayCastLeft.enabled = false

func switch_rc_right_off():
	$Raycasts/RayCastRight.enabled = false
	
func _on_jump_buffer_timeout() -> void:
	jump_buffer = false

func _on_coyote_timer_timeout() -> void:
	coyote_jump = false

func _on_comp_2d_hurtbox_hurt(_damage: Variant) -> void:
	update_animation(animations.DIE)

func _on_character_animated_animation_finished() -> void:
	if player_died_received:
		#If root node's name is not "World" then we are in debug mode and need restarting
		if get_tree().current_scene.name != "World":
			get_tree().reload_current_scene()
		else:
			player_died.emit()

func _on_hurt_detection_area_body_entered(_body: Node2D) -> void:
	update_animation(animations.DIE)
