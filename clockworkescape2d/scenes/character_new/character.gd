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
@export var gravity_coef : float = 5.0
@export var move_acc : float = 50.0
@export var move_dec : float = 100.0
@export var wall_jump_count_max : int = 1

@onready var fsm: CompFsmNode = $FSM
@onready var animation_player_rotate: AnimationPlayer = $AnimationPlayer
@onready var jump_buffer_timer: Timer = $JumpBuffer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var grab_timer: Timer = $GrabTimer
@onready var squash_marker: Marker2D = $SquashMarker

@onready var gear_with_animation: AnimatedSprite2D = $SquashMarker/CharacterAnimated
@onready var shape_cast_2d: ShapeCast2D = $ShapeCast2D
@onready var line_2d: Line2D = $Line2D
@onready var sparks: GPUParticles2D = $Sparks

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
var fall_velocity : float = 1200.0
var curr_nr_collectables : int = 0
var is_player_moving : bool = false
func _ready() -> void:
	jump_count = max_jump_count
	player_died_received= false
	wall_jump_count = wall_jump_count_max
	gravity = Vector2(0, fall_gravity)
	update_animation(animations.SPAWN)
	fsm.start()

func _process(delta: float) -> void:
	Debug.print_value("State:", fsm.current_state)
	Debug.print_value("JumpCount:", jump_count)
	jump_velocity = -(sqrt(2 * jump_gravity * jump_height))
	apply_gravity(delta)
	#if is_movable:
		#move_and_slide()
	if rc_not_colliding() and !shape_cast_2d.is_colliding():
		grab_timer.start()
	print(velocity)

func apply_gravity(delta):
	velocity += gravity * delta
	if velocity.y > 0:
		velocity.y = min(velocity.y, fall_velocity)

func move_player_x(directionX : int, speed : float = max_speed):
	if directionX != 0:
		velocity.x = move_toward(velocity.x, speed * directionX, move_acc)  #speed * directionX
	else:
		velocity.x = move_toward(velocity.x, 0, move_dec)

func move_player_y(directionY : int,  speed : float = max_speed):
	velocity.y = speed * directionY

func move_player_position(move_delta):
	global_position += move_delta

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
			reset_collectables()
			gear_with_animation.play("break")
		animations.SPAWN:
			is_movable = true

func update_collectables_number():
	curr_nr_collectables += 1
	GameManager.collected_objects += 1

func reset_collectables():
	#Reset number of collected objects to the number before this level
	GameManager.collected_objects = GameManager.collected_objects - curr_nr_collectables
	curr_nr_collectables = 0

func get_nr_of_collected_items()->int:
	return curr_nr_collectables

func normalize_movement(direction : float) -> int:
	var dir : int = 0
	if direction < 0:
		dir = -1
	elif direction > 0:
		dir = 1
	else:
		dir = 0
	return dir
#------------------------RayCast management -----------------------------
func rc_left() -> bool:
	return $Raycasts/RayCastLeft.is_colliding()
func rc_right() -> bool:
	return $Raycasts/RayCastRight.is_colliding()
func rc_up() -> bool:
	return $Raycasts/RayCastUp.is_colliding()
func rc_down() -> bool:
	return $Raycasts/RayCastDown.is_colliding()

func get_wall_grab_collider():
	if rc_left():
		return get_collider_left()
	elif rc_up():
		return get_collider_up()
	elif rc_right():
		return get_collider_right()
	elif rc_down():
		return get_collider_down()

func rc_not_colliding():
	return !rc_right() and !rc_left() and !rc_up() and !rc_down()

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

func get_wall_collision():
	return $Raycasts/RayCastWallLeft.is_colliding() or $Raycasts/RayCastWallRight.is_colliding()

func get_wall_collider():
	if $Raycasts/RayCastWallLeft.is_colliding():
		return $Raycasts/RayCastWallLeft.get_collider()
	elif $Raycasts/RayCastWallRight.is_colliding():
		return $Raycasts/RayCastWallRight.get_collider()

func get_rc_collider():
	if $Raycasts/RayCastLeft.is_colliding():
		return  $Raycasts/RayCastLeft.get_collider()
	elif $Raycasts/RayCastRight.is_colliding():
		return  $Raycasts/RayCastRight.get_collider()
	elif $Raycasts/RayCastUp.is_colliding():
		return  $Raycasts/RayCastUp.get_collider()

func _on_jump_buffer_timeout() -> void:
	jump_buffer = false

func _on_coyote_timer_timeout() -> void:
	coyote_jump_timer_started = false
	coyote_jump = false

func _on_comp_2d_hurtbox_hurt(_damage: Variant) -> void:
	update_animation(animations.DIE)

func _on_hurt_detection_area_body_entered(_body: Node2D) -> void:
	update_animation(animations.DIE)

func _on_character_animated_animation_finished() -> void:
	if player_died_received:
		#If root node's name is not "World" then we are in debug mode and need restarting
		if get_tree().current_scene.name != "World":
			get_tree().reload_current_scene()
		else:
			player_died.emit()

func _on_grab_timer_timeout() -> void:
	set_can_grab(true)
