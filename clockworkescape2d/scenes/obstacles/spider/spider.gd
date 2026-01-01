extends CharacterBody2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

enum Direction {LEFT, RIGHT}
@export var speed : float = 50.0
@export var movement_range : float = 100.0
@export var init_direction : Direction = Direction.RIGHT

var fall_velocity : float = 1200.0
var direction : int = 1
var init_position : Vector2 = Vector2.ZERO

func _ready() -> void:
	init_position = global_position

	if init_direction  == Direction.RIGHT:
		direction = 1
	elif init_direction == Direction.LEFT:
		direction = -1

func _process(delta: float) -> void:
	# Apply movement
	velocity.x = direction * speed

	# Apply gravity (if you want the enemy to stay on the ground)
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	move_and_slide()

	var offset = global_position.x - init_position.x
	var limit
	if init_direction == Direction.RIGHT:
		limit = movement_range
	else:
		limit = -movement_range

	# If we go past the limit in either direction, reverse
	if (direction == 1 and offset >= max(0, limit)) or (direction == -1 and offset <= min(0, limit)):
		direction *= -1

	animated_sprite_2d.flip_h = (direction > 0)
