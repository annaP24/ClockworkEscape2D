extends Node2D

const PLAYER_COLLISION_LAYER: int = 1 << 4

@export var switch_1: Switch
@export var switch_2: Switch
@export var wait_timeout : float = 0.3
@export var move_up_speed : float = 200.0
@export var move_down_speed : float = 50.0
@onready var sprites: StaticBody2D = $Sprites
@onready var door_collision: CollisionShape2D = $Sprites/CollisionShape2D2
@onready var move_delay_timer: Timer = $MoveDelayTimer
@onready var sparks: GPUParticles2D = $Sparks
@export_enum("Vertical", "Horizontal") var movement_direction: String = "Vertical"
@export_storage var move_vertical: bool = false

var max_move_offset : float = 2 * 64.0
var init_position : Vector2 = Vector2.ZERO
var target_position : Vector2 = Vector2.ZERO
var current_target : Vector2 = Vector2.ZERO
var move_speed : float = 0.0
var tracked_player: PlayerFsmCustomDataLayer
var tracked_player_shape: CollisionShape2D
var approach_side: float = 0.0
var sweep_shape := RectangleShape2D.new()
var sweep_query := PhysicsShapeQueryParameters2D.new()

func _ready() -> void:
	move_delay_timer.wait_time = wait_timeout
	init_position = global_position
	move_speed = move_up_speed
	sparks.emitting = false
	var movement_offset := Vector2.UP if movement_direction == "Vertical" else Vector2.LEFT
	target_position = init_position + movement_offset * max_move_offset
	current_target = init_position
	sweep_query.shape = sweep_shape
	sweep_query.collision_mask = PLAYER_COLLISION_LAYER
	if not switch_1.is_active.is_connected(_on_switch_is_active.bind(switch_1)):
		switch_1.is_active.connect(_on_switch_is_active.bind(switch_1))
	if not switch_1.is_not_active.is_connected(_on_switch_is_not_active):
		switch_1.is_not_active.connect(_on_switch_is_not_active)
	if switch_2 and switch_2 != switch_1:
		if not switch_2.is_active.is_connected(_on_switch_is_active.bind(switch_2)):
			switch_2.is_active.connect(_on_switch_is_active.bind(switch_2))
		if not switch_2.is_not_active.is_connected(_on_switch_is_not_active):
			switch_2.is_not_active.connect(_on_switch_is_not_active)

func _physics_process(delta: float) -> void:
	_update_approach_side()
	var next_position := sprites.global_position.move_toward(current_target, move_speed * delta)
	if current_target == init_position and next_position != sprites.global_position:
		if not _clear_closing_path(next_position - sprites.global_position):
			return
	sprites.global_position = next_position
	if sprites.global_position == target_position:
		sparks.emitting = false


func _on_switch_is_active(activated_switch: Switch):
	tracked_player = activated_switch.player
	tracked_player_shape = tracked_player.get_node("CollisionShape2D") as CollisionShape2D if is_instance_valid(tracked_player) else null
	approach_side = 0.0
	_update_approach_side()
	move_delay_timer.stop() # Cancel timers
	current_target = target_position
	sparks.emitting = true
	move_speed = move_up_speed

func _update_approach_side() -> void:
	if not is_instance_valid(tracked_player):
		return
	var axis := door_collision.global_transform.x.normalized()
	var distance := (tracked_player_shape.global_position - door_collision.global_position).dot(axis)
	var clearance := _player_clearance(tracked_player_shape)
	if absf(distance) >= clearance or approach_side == 0.0:
		approach_side = signf(distance) if not is_zero_approx(distance) else 1.0

func _clear_closing_path(motion: Vector2) -> bool:
	var rectangle := door_collision.shape as RectangleShape2D
	var local_motion := door_collision.global_transform.basis_xform_inv(motion)
	sweep_shape.size = rectangle.size + local_motion.abs()
	sweep_query.transform = door_collision.global_transform
	sweep_query.transform.origin += motion / 2.0
	var space := get_world_2d().direct_space_state
	for result in space.intersect_shape(sweep_query):
		var player := result.collider as PlayerFsmCustomDataLayer
		if not player:
			continue
		var player_shape := player.get_node("CollisionShape2D") as CollisionShape2D
		var axis := door_collision.global_transform.x.normalized()
		var side := approach_side if player == tracked_player and approach_side != 0.0 else signf((player_shape.global_position - door_collision.global_position).dot(axis))
		if side == 0.0:
			side = 1.0
		var clearance := _player_clearance(player_shape) + 1.0
		var distance := (player_shape.global_position - door_collision.global_position).dot(axis) * side
		var push_distance := clearance + maxf(0.0, motion.dot(axis) * side) - distance
		player.move_and_collide(axis * side * maxf(push_distance, 0.0))
		# A wall can prevent the push; never close into the player in that case.
		if (player_shape.global_position - door_collision.global_position).dot(axis) * side < clearance - 0.5:
			return false
	return true

func _player_clearance(player_shape: CollisionShape2D) -> float:
	var rectangle := door_collision.shape as RectangleShape2D
	var circle := player_shape.shape as CircleShape2D
	return rectangle.size.x * door_collision.global_transform.x.length() / 2.0 \
		+ circle.radius * maxf(player_shape.global_transform.x.length(), player_shape.global_transform.y.length())

func _on_switch_is_not_active():
	move_delay_timer.start()
	sparks.emitting = false

func _on_move_delay_timer_timeout() -> void:
	if switch_2:
		move_speed = move_down_speed
		current_target = init_position
	if sprites.global_position.distance_to(current_target) != 0:
		move_speed = move_down_speed
		current_target = init_position
