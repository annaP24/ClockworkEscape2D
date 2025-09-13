@tool
extends AnimatableBody2D
class_name PlatformBase
@export var is_moving : bool = false
@export var is_move_vertical : bool = false
@export var is_start_right : bool = false
@export var is_start_up : bool = false
@export var move_range : float = 0.0
@export var move_speed : float = 70
@export var wall_type : wall_type_enum = wall_type_enum.NORMAL

enum wall_type_enum {NORMAL, TIMED, INVERSE, AUTO}
var half_range : float = 0.0
var move_up : bool = false
var move_right : bool = false
var delta_movement : float = 0.0
var move_half_range : float = 0.0 

func _ready() -> void:
	check_configuration()	
	move_up = is_start_up
	move_right = is_start_right
	move_half_range = move_range / 2
	
func _physics_process(delta: float) -> void:
	if is_moving:
		if is_move_vertical:
			move_vertical(delta)
		else:
			move_horizontal(delta)
			
func check_configuration():
	if (is_move_vertical and is_start_right) or (!is_move_vertical and is_start_up):
		print("Cannot move vertical and horisontal at the same time, abort")
		get_tree().quit()
	if is_moving and move_range == 0.0:
		print("Range for platform not defined, abort")
		get_tree().quit()

func move_horizontal(delta):
	if move_right:
		position.x += move_speed  * delta
		delta_movement += move_speed * delta
		if delta_movement >= move_range:
			move_right = false
			delta_movement = 0.0 
	else:
		position.x -= move_speed  * delta
		delta_movement += move_speed * delta
		if delta_movement >= move_range:
			move_right = true
			delta_movement = 0.0

func move_vertical(delta):
	if move_up:
		position.y -= move_speed  * delta
		delta_movement += move_speed * delta
		if delta_movement >= move_range:
			move_up = false
			delta_movement = 0.0 
	else:
		position.y += move_speed  * delta
		delta_movement += move_speed * delta
		if delta_movement >= move_range:
			move_up = true
			delta_movement = 0.0 
	
func get_is_moving():
	return is_moving
