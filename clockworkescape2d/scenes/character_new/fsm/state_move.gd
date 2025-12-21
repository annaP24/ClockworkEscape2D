extends FsmNodeState

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	player.jump_button_released = true
	player.coyote_jump = true
	var inputX = Input.get_axis("left", "right")
	#Update animation
	if inputX != 0:
		if inputX > 0:
			player.update_animation(player.animations.RUN_RIGHT)
		elif inputX < 0:
			player.update_animation(player.animations.RUN_LEFT)

func Physics_Update(_delta):
	#Apply gravity
	player.gravity = Vector2(0, player.fall_gravity)
	#Move player x-axis
	var inputX = Input.get_axis("left", "right")
	#Update animation
	if inputX != 0:
		if inputX > 0:
			player.update_animation(player.animations.RUN_RIGHT)
		elif inputX < 0:
			player.update_animation(player.animations.RUN_LEFT)

	player.move_player_x(inputX)

	# cojote timer start
	if not player.is_on_floor() and player.coyote_jump == true and player.coyote_jump_timer_started == false:
		player.coyote_jump_timer_started = true
		player.coyote_timer.start(player.coyote_timeout)

	#Change states
	if Input.is_action_just_pressed("jump"):
		change_state("JumpState")
	elif !player.is_on_floor():
		player.jump_count -= 1
		change_state("FallState")
	elif inputX == 0:
		change_state("IdleState")
#	----------Wall Walk ----------------------------
	elif player.rc_left() and Input.is_action_pressed("left"):
		change_state("IdleState")
	elif player.rc_right() and Input.is_action_pressed("right"):
		change_state("IdleState")
