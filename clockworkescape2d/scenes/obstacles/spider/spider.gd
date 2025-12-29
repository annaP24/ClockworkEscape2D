extends CharacterBody2D
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var speed : float = 50.0
@export var movement_range : float = 100.0
var fall_velocity : float = 1200.0
var direction : int = 1
var init_position : Vector2 = Vector2.ZERO
func _ready() -> void:
	init_position = global_position

func _process(delta: float) -> void:
	# Calculate how far we are from the starting point
	var current_distance = global_position.x - init_position.x

	# Logic to switch directions
	if direction == 1 and current_distance >= movement_range:
		direction = -1
		sprite_2d.flip_h = true # Flip sprite to face left
	elif direction == -1 and current_distance <= 0:
		direction = 1
		sprite_2d.flip_h = false # Flip sprite to face right

	# Apply movement
	velocity.x = direction * speed

	# Apply gravity (if you want the enemy to stay on the ground)
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	move_and_slide()
