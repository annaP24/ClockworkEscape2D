extends FsmNodeState	
var wall_direction : int = 0

func Physics_Update(_delta):	
	#Move player x-axis
	var inputX = Input.get_axis("left", "right")
	player.move_player_x(inputX, player.max_speed)

	#Apply gravity
	if player.velocity.y > 0: #Falling
		player.gravity = Vector2(0, player.fall_gravity)
	elif player.velocity.y < 0: # Rising
		player.gravity = Vector2(0, player.fall_gravity * 1.15) #player.gravity_coef)

	#Double jump
	if Input.is_action_just_pressed("jump"):
		#If double jump available jump again
		if player.jump_count > 0:
			change_state("JumpState")
		# jump buffer start
		if !player.is_on_floor():
			player.jump_buffer = true
			player.jump_buffer_timer.start(player.jump_buffer_timeout)

	if Input.is_action_just_pressed("jump") and player.coyote_jump: 
		change_state("JumpState")
	elif player.is_on_floor():
		change_state("Idle")
	if player.rc_right():
		change_state("WallState")
	elif player.rc_left():
		change_state("WallState")
	elif player.rc_up():							#TODO: Ist das beim fallen möglich?
		change_state("CeelingState")
#	---------- Wall Jumps -----------------------
	if player.is_on_wall():
		if Input.is_action_just_pressed("jump"):
			#player.velocity.x = -500 #TODO: man könnte eine kraft entgegen der wand einfügen
			if player.wall_jump_count > 0:
				player.jump_count = player.max_jump_count
				player.wall_jump_count = 0
				change_state("JumpState")
		
func check_wall() -> bool:
		if player.rc_left():
			wall_direction = 1
		elif player.rc_right():
			wall_direction = -1
		else:
			return false
		return true
