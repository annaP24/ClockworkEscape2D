extends FsmNodeState

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	player.jump_button_released = true
	player.wall_jump_count = player.wall_jump_count_max
	player.coyote_jump = true
	player.set_can_grab(true)
	player.switch_ray_casts_on()
	player.update_animation(player.animations.IDLE)

func Physics_Update(_delta):
	if player.is_movable:
		player.update_animation(player.animations.IDLE)
		#Move player x-axis
		player.move_player_x(0)

		#Move player y-axis
		player.gravity = Vector2(0, player.fall_gravity)

		#Input reactions
		if Input.is_action_pressed("jump") and player.jump_buffer:
			change_state("JumpState")
		elif Input.is_action_just_pressed("jump") and player.jump_count > 0:
			change_state("JumpState")
		elif Input.is_action_pressed("right") and !player.rc_right() and !player.rc_down():
			change_state("RunState")
		elif Input.is_action_pressed("left") and !player.rc_left()and !player.rc_down():
			change_state("RunState")
		elif player.rc_left()  and  Input.is_action_pressed("up"):
			change_state("WallState")
		elif player.rc_right() and Input.is_action_pressed("up"):
			change_state("WallState")
		elif player.rc_down():
			change_state("WallState")

		player.move_and_slide()
