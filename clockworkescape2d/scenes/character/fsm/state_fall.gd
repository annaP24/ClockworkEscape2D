extends FsmNodeState	
var wall_direction : int = 0

func Physics_Update(_delta):
	#Move player x-axis
	var inputX = Input.get_axis("left", "right")
	player.move_player_x(inputX, player.max_speed)
	#Move player y-axis
	player.gravity = Vector2(0, player.fall_gravity)

	#Apply gravity
	if player.velocity.y > 0:
		if !player.jump_button_released:
			player.gravity = Vector2(0, player.fall_gravity)
		else:
			player.gravity = Vector2(0, player.fall_gravity * player.gravity_coef)
	elif player.velocity.y < 0:
		player.gravity = Vector2(0, player.fall_gravity)

	#Double jump
	if Input.is_action_just_pressed("jump"):
		#If double jump available jump again
		if player.jump_count > 0:
			change_state("JumpState")
		# jump buffer start
		if !player.is_on_floor():
			Debug.print_value("JumpBufferTimerStarted", true)
			player.jump_buffer = true
			player.jump_buffer_timer.start(player.jump_buffer_timeout)
	elif Input.is_action_just_pressed("dash"):
		change_state("DashState")	
		
	# jump buffer jump
	if player.is_on_floor() and player.jump_buffer:
		change_state("JumpState")
	elif player.is_on_floor():
		change_state("Idle")
	if player.rc_right():
		var wall = player.get_collider_right()
		if !wall.is_in_group("basic"):
			change_state("WallRightState")
	elif player.rc_left():
		var wall = player.get_collider_left()
		if !wall.is_in_group("basic"):
			change_state("WallLeftState")
	elif player.rc_up():
		var wall = player.get_collider_up()
		if !wall.is_in_group("basic"):
			change_state("CeelingState")
			
#	---------- Wall Jumps -----------------------
	if player.is_on_wall() and Input.is_action_just_pressed("jump"):
		player.jump_count  = 1	
		if check_wall():
			player.velocity.x = wall_direction * player.max_speed * GameManager.wall_jump_coaf			
			player.velocity.y = 1 * player.max_speed * GameManager.wall_jump_coaf
			change_state("JumpState")
		
func check_wall() -> bool:
		var wall
		if player.rc_left():
			wall = player.get_collider_left()
			wall_direction = 1
		elif player.rc_right():
			wall = player.get_collider_right()
			wall_direction = -1
		if wall != null and wall.is_in_group("basic"):
			return true
		else:
			return false
