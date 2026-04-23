extends GPUParticles2D

@onready var player : PlayerFsmCustomDataLayer

func _ready() -> void:
	player = get_parent()

func _process(_delta: float) -> void:
	update_sparks()
	
func update_sparks():
	if player.is_on_floor() and abs(player.velocity.x) > 10:
		emitting = true
		# Set sparks under the gear
		position = Vector2(0,33)
		#If moving right dierection is -1
		if player.velocity.x > 0:
			process_material.direction = Vector3(-1,-0.5, 0)
		#If moving left dierection is 1
		else:
			process_material.direction = Vector3(1, -0.5, 0)
	#elif player.is_on_ceiling() and abs(player.velocity.x) > 10:
		#emitting = true
		## Set sparks under the gear
		#position = Vector2(0,-33)
		## If moving right dierection is -1
		#if player.velocity.x > 0:
			#process_material.direction = Vector3(-1,0.5, 0)
		## If moving left dierection is 1
		#else:
			#process_material.direction = Vector3(1, 0.5, 0)
	elif player.is_on_wall() and abs(player.velocity.y) > 10:
		emitting = true
		# Set sparks under the gear
		if player.get_walkable_wall_side() == player.WallSide.LEFT:
			position = Vector2(-33, 0)
		elif  player.get_walkable_wall_side() == player.WallSide.RIGHT:
			position = Vector2(33, 0)

		# If moving right dierection is -1
		if player.velocity.y > 0:
			process_material.direction = Vector3(-0.5, 1.0, 0)
		# If moving left dierection is 1
		else:
			process_material.direction = Vector3(0.5, -1.0 ,0)
	else:
		emitting = false
