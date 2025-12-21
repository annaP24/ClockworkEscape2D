extends FsmNodeState

func Physics_Update(_delta):
	#Move player x-axis
	var inputX = Input.get_axis("left", "right")
	player.move_player_x(inputX, player.max_speed)

	#Apply gravity
	if player.velocity.y > 0: #Falling
		player.gravity = Vector2(0, player.fall_gravity)
	elif player.velocity.y < 0: # Rising
		player.gravity = Vector2(0, player.fall_gravity * 1.15)
	elif player.velocity.y == 0:
		player.gravity = Vector2(0, player.fall_gravity)

	#Double jump
	if Input.is_action_just_pressed("jump"):
		#If double jump available jump again
		if player.jump_count > 0:
			change_state("JumpState")
		#Wall jump
		elif player.get_wall_collision() and player.wall_jump_count > 0:
			player.wall_jump_count = 0
			change_state("JumpState")
		# jump buffer start
		player.jump_buffer = true
		player.jump_buffer_timer.start(player.jump_buffer_timeout)

	elif Input.is_action_just_pressed("jump") and player.coyote_jump:
		print("jump cojote")
		change_state("JumpState")
	elif player.is_on_floor():
		change_state("IdleState")
	elif player.rc_right() or player.rc_left() or player.rc_up():
		if player.is_on_floor():
			change_state("StateIdle")
		else:
			if player.get_can_grab():
				change_state("WallState")
