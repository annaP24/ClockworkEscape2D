extends Projectile

var rotation_direction : float = 1.0

func _ready() -> void:
	if current_direction == Vector2.LEFT:
		rotation_direction = -1.0
	elif current_direction == Vector2.RIGHT:
		rotation_direction = 1.0

func _process(delta: float) -> void:
	rotation_degrees += delta * rotation_angle * rotation_direction
	global_position += Vector2(1, 1) * speed * current_direction
