extends FsmNodeState

func Enter(player_node):
	super(player_node)
	#player.jump_button_released = false
	#player.gravity = Vector2(0, player.jump_gravity)
	jump()
	player.jump_count -= 1
	player_node.switch_ray_casts_on()
	player.jump_buffer = false
	player.can_coyote_jump = false

func jump():
	player.velocity.y = player.jump_velocity

func Physics_Update(delta):
	if not player.is_movable:
		return

	#Move player x-axis
	var inputX = Input.get_axis("left", "right")
	inputX = player.normalize_movement(inputX)
	player.move_player_x(inputX)

	# Move player y-axis

	#Apply gravity
	player.apply_gravity(player.jump_gravity, delta)

	player.move_and_slide()
	var colliders = player.get_colliding_tile_type()

	if !Input.is_action_pressed("jump"):
		#player.jump_button_released = true
		change_state("FallState")
	elif Input.is_action_just_pressed("jump") and colliders.has("basic") and player.wall_jump_count > 0:
		print("Jump from fall-wall state")
		player.wall_jump_count = 0
		change_state("JumpState")
	elif player.velocity.y >= 0:
		change_state("FallState")
