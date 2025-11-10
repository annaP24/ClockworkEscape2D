extends FsmNodeState

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	player.jump_button_released = true
	player.wall_jump_count = player.wall_jump_count_max # TODO player statt player_node?
	player.coyote_jump = true
	player.can_grab = true
	player.switch_ray_casts_on()
	#Update animation
	player.update_animation(player.animations.IDLE)

func Physics_Update(_delta):
	if player.is_movable:
		player.update_animation(player.animations.IDLE)

		Debug.print_value("Player rc DOWN:", player.rc_down())	
		Debug.print_value("Player on floor:", player.is_on_floor())	
		#Move player x-axis
		player.move_player_x(0)

		#Move player y-axis
		player.gravity = Vector2(0, player.fall_gravity)
		if player.coil_push_active:
			player.jump_count = 0
		#Input reactions
		if Input.is_action_pressed("right") and !player.rc_right(): 
			change_state("RunState")
		elif Input.is_action_pressed("left") and !player.rc_left():
			change_state("RunState")
		elif player.rc_left()  and  Input.is_action_pressed("up"):
			change_state("WallState")
		elif player.rc_right() and Input.is_action_pressed("up"):
			change_state("WallState")
		elif Input.is_action_just_pressed("jump") and player.coil_push_active:
			player.coil_jump_pressed = true
		elif Input.is_action_just_pressed("jump") and player.jump_count > 0:
			change_state("JumpState")
		elif Input.is_action_pressed("jump") and player.jump_buffer:  
			change_state("JumpState")
		elif player.rc_down():
			change_state("WallState")
