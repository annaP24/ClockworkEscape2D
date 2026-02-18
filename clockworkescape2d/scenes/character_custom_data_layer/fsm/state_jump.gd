extends FsmNodeState

func Enter(player_node):
	super(player_node)
	jump()
	player.jump_count -= 1
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

	#Apply gravity
	player.apply_gravity(player.jump_gravity, delta)

	player.move_and_slide()

	if !Input.is_action_pressed("jump"):
		#player.jump_button_released = true
		change_state("FallState")
	elif (Input.is_action_just_pressed("jump") or player.jump_buffer) and player.last_wall_direction != player.WallSide.NONE and player.wall_jump_count > 0:
		print("Fall - jump")
		player.wall_jump_count = 0
		change_state("JumpState")
		#change_state("WallJumpState")
	elif player.velocity.y >= 0:
		change_state("FallState")
