extends FsmNodeState

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	Debug.print_value("FallDownTimestamp",  Time.get_time_dict_from_system() )
	Debug.print_value("FallDownTimestampMS",  Time.get_ticks_msec() )
	
func Physics_Update(_delta):
	if player.is_movable:
		#Move player x-axis
		player.move_player_x(0)
		#Move player y-axis
		player.gravity = Vector2(0, player.fall_gravity)
		#Update animation
		player.update_animation(player.animations.IDLE)
		if player.coil_push_active:
			player.jump_count = 0
		#Input reactions
		if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
			change_state("RunState")	
		elif Input.is_action_just_pressed("jump") and player.coil_push_active:
			Debug.print_value("ColiJumpPressed", true)
			player.coil_jump_pressed = true
		elif Input.is_action_just_pressed("jump") and player.jump_count > 0:
			change_state("JumpState")	
		elif Input.is_action_just_pressed("jump") and player.jump_buffer:
			Debug.print_value("ColiJumpPressed", false)
			change_state("JumpState")
		elif Input.is_action_just_pressed("dash"):
			change_state("DashState")	
