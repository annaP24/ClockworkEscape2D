extends CharacterBody2D

class_name PlayerFsmCustomDataLayer

signal player_died

@export var move_speed : float = 300.0
@export var max_jump_count : int = 1
@export var jump_height : float = 192 # 3*64px
@export var jump_gravity : float = 2000.0
@export var fall_gravity : float = 3600.0
@export var jump_buffer_timeout : float = 0.3
@export var coyote_timeout : float = 0.1
@export var idle_fall_coyote_timeout : float = 0.5
@export var wall_coyote_timeout : float = 0.1
@export var gravity_coef : float = 5.0
@export var move_acc : float = 50.0
@export var move_dec : float = 100.0
@export var wall_jump_count_max : int = 1

@onready var fsm: CompFsmNode = $FSM
@onready var animation_player_rotate: AnimationPlayer = $AnimationPlayer
@onready var jump_buffer_timer: Timer = $JumpBuffer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var wall_jump_coyote_timer: Timer = $WallJumpCoyoteTimer
@onready var grab_timer: Timer = $GrabTimer
@onready var squash_marker: Marker2D = $SquashMarker
@onready var gear_with_animation: AnimatedSprite2D = $SquashMarker/CharacterAnimated
@onready var shape_cast_2d: ShapeCast2D = $ShapeCast2D
@onready var sparks: GPUParticles2D = $Sparks
@onready var ray_cast_right: RayCast2D = $JumpRayCasts/RayCastRight
@onready var ray_cast_left: RayCast2D = $JumpRayCasts/RayCastLeft
@onready var point_light_2d: PointLight2D = $PointLight2D

enum animations {RUN_LEFT, RUN_RIGHT, JUMP, IDLE, DIE, SPAWN}

var gravity : float = 0.0
var jump_buffer : bool = false
var jump_count : int = 0
var can_coyote_jump : bool = false
var can_wall_coyote_jump : bool = false
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
var last_wall_direction : WallSide = WallSide.NONE

var wall_kick_acceleration = 500
var wall_kick_deceleration = 100
var wall_jump_y_speed_peak = 0 # y-speeed at witchh the wall jump will end and chage to fall state
var wall_jump_velocity = -800
var wall_jump_h_speed = 300

enum WallSide {LEFT = -1, RIGHT = 1, NONE = 0, DOWN = 2, UP = -2}

# TODO Spawn State und Die State hinzufügen


func _ready() -> void:
	is_movable = true
	jump_count = max_jump_count
	player_died_received = false
	wall_jump_count = wall_jump_count_max
	update_animation(animations.SPAWN)		#TODO Ins den spawn state schieben
	jump_velocity = -(sqrt(2 * jump_gravity * jump_height))
	wall_jump_velocity = jump_velocity
	fsm.start()

func _process(_delta: float) -> void:
	Debug.print_value("State: ", fsm.current_state)
	# ruecksetzen wenn keine berüehrung mehr vorhanden
	if not get_can_grab() and get_collision_points().size() == 0:
		set_can_grab(true)
	check_is_on_wall()
	point_light_2d.energy = lerp(point_light_2d.energy, randf_range(1.2, 1.8), 0.1)

func apply_gravity(new_gravity : float, delta : float):
	velocity.y += new_gravity * delta
	velocity.y = min(velocity.y, fall_velocity)

func move_player_x(directionX : float, acc : float = move_acc, dec : float = move_dec):
	if directionX != 0:
		velocity.x = move_toward(velocity.x, move_speed * directionX, acc)  #speed * directionX
	else:
		velocity.x = move_toward(velocity.x, 0, dec)

func move_player_y(directionY : float,  speed : float = move_speed):
	velocity.y = speed * directionY		# TODO: Ändern zu Move_Toward???

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

func normalize_movement(direction : float) -> float:
	if direction < 0.0:
		return -1.0
	elif direction > 0.0:
		return 1.0
	else:
		return 0.0

func check_is_on_wall():
	if is_on_wall():
		wall_jump_coyote_timer.start(wall_coyote_timeout)
		can_wall_coyote_jump = true

#------------------------RayCast management -----------------------------
func get_colliding_tile_type() -> Array:
	var current_tiles = []
	for i in get_slide_collision_count():
		var collision_info = get_slide_collision(i)
		var collider = collision_info.get_collider()

		# Check if we hit a tilemap
		if collider is TileMapLayer:
			# Get the collision position
			# A bit of normal is subtracted to "push" the point into the tile
			var pos = collision_info.get_position() - collision_info.get_normal()

			# Convert global position to map coordinates
			var map_pos = collider.local_to_map(collider.to_local(pos))
			# Get the TileData at that coordinate
			var tile_data = collider.get_cell_tile_data(map_pos)
			if tile_data:
				# Retrive custom ID
				var tile_type = tile_data.get_custom_data("tile_id")
				if tile_type != "" and !current_tiles.has(tile_type):
					current_tiles.append(tile_type)
	return current_tiles

func get_walkable_wall_side() -> WallSide:
	if shape_cast_2d.is_colliding():
		# Check Slide Collisions (Active movement)
		for coll_point in get_slide_collision_count():
			var collision_info = get_slide_collision(coll_point)
			var collider = collision_info.get_collider()

			if collider is TileMapLayer:
				# Push position slightly in to be sure which tile map cell is it
				var pos = collision_info.get_position() - collision_info.get_normal() * 4
				var map_pos = collider.local_to_map(collider.to_local(pos))
				var tile_data = collider.get_cell_tile_data(map_pos)

				if tile_data and tile_data.get_custom_data("tile_id") == "walkable":
					var normal = collision_info.get_normal()
					return get_wall_side_from_normal(normal)
	# Check ShapeCast if no "walkable" tile was detected (Idle case)
	if shape_cast_2d.is_colliding():
		for collision_point in shape_cast_2d.get_collision_count():
			var collider = shape_cast_2d.get_collider(collision_point)
			if collider is TileMapLayer:
				# Get collision normal from ShapeCast
				var normal = shape_cast_2d.get_collision_normal(collision_point)
				return get_wall_side_from_normal(normal)

	return WallSide.NONE

func get_wall_direction():
	if ray_cast_right.is_colliding():
		last_wall_direction = WallSide.RIGHT
	elif ray_cast_left.is_colliding():
		last_wall_direction = WallSide.LEFT
	else:
		last_wall_direction = WallSide.NONE

func set_can_grab(grab : bool):
	# rücksetzen des states nach einer gewissen zeit
	can_grab = grab

func get_can_grab() -> bool:
	return can_grab

func get_collision_points() -> Array:
	var collision_points : Array = []
	for point_number in shape_cast_2d.get_collision_count():
		var point = shape_cast_2d.get_collision_point(point_number)
		collision_points.append(point)
	return collision_points

func get_movable_wall_side() -> WallSide:
	for collision_point in shape_cast_2d.get_collision_count():
		var collider = shape_cast_2d.get_collider(collision_point)
		if collider is PlatformDetectionArea:
			# Get collision normal from ShapeCast
			var normal = shape_cast_2d.get_collision_normal(collision_point)
			return get_wall_side_from_normal(normal)
	return WallSide.NONE

func get_movable_wall_collider():
	for collision_point in shape_cast_2d.get_collision_count():
		var collider = shape_cast_2d.get_collider(collision_point)
		if collider is PlatformDetectionArea:
			return collider

func get_wall_side_from_normal(normal) -> WallSide:
	# If normal.x is positive, wall is on the left
	# If normal.x is negative, wall is on the right
	# If normal.y is positive, wall is on the up
	# If normal.y is negative, wall is on the down
	if abs(normal.x) > abs(normal.y):
		if abs(normal.x) > 0.1:
			if normal.x > 0.1:
				return WallSide.LEFT
			elif normal.x < -0.1:
				return WallSide.RIGHT
	else:
		if abs(normal.y) > 0.1:
			if normal.y > 0.1:
				return WallSide.UP
			elif normal.y < -0.1:
				return WallSide.DOWN
	return WallSide.NONE
# -------------------- Timers -------------------------------------------------
func _on_jump_buffer_timeout() -> void:
	jump_buffer = false

func _on_coyote_timer_timeout() -> void:
	can_coyote_jump = false

func _on_wall_jump_coyote_timer_timeout() -> void:
	can_wall_coyote_jump = false

# -------------------- On Signal Received -------------------------------------
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
