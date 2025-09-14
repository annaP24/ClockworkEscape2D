extends FsmNodeState

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	player.jump_button_released = true
	player_node.wall_jump_count = player.wall_jump_count_max # TODO player statt player_node?
	player.coyote_jump = true

func Physics_Update(_delta):
	if player.is_movable:
		#Move player x-axis
		player.move_player_x(0)
		#Move player y-axis
		player.gravity = Vector2(0, player.fall_gravity)
		#Update animation
		player.update_animation(player.animations.IDLE)		# TODO: sollte im enter stehen
		if player.coil_push_active:
			player.jump_count = 0
		#Input reactions
		if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
			change_state("RunState")	
		elif Input.is_action_just_pressed("jump") and player.coil_push_active:
			player.coil_jump_pressed = true
		elif Input.is_action_just_pressed("jump") and player.jump_count > 0:
			change_state("JumpState")	
		#elif Input.is_action_just_pressed("jump") and player.jump_buffer:
		elif Input.is_action_pressed("jump") and player.jump_buffer:    # TODO: ist is on floor nötig, evtl. Input.is_action_pressed("jump")
			change_state("JumpState")
