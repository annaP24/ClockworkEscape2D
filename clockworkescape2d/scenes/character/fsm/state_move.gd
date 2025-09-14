extends FsmNodeState

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	player.jump_button_released = true
	var inputX = Input.get_axis("left", "right")
	#Update animation								# TODO: Ich denke es sollte im enter sein und automatisch loopen. warum es hier funktioniert, keine ahnung
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
	player.move_player_x(inputX)
	#Update animation								# TODO: Ich denke es sollte im enter sein und automatisch loopen. warum es hier funktioniert, keine ahnung
	#if inputX != 0:
		#if player.velocity.x > 0:
			#player.update_animation(player.animations.RUN_RIGHT)
		#elif player.velocity.x < 0:
			#player.update_animation(player.animations.RUN_LEFT)

	# cojote timer start
	if player.is_on_floor():
		player.coyote_jump = true
		player.coyote_jump_timer_started = true
	if not player.is_on_floor() and player.coyote_jump == true and player.coyote_jump_timer_started == true:
		player.coyote_jump_timer_started = false
		player.coyote_timer.start(player.coyote_timeout)

	#Change states	
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		Debug.print_value("FallFromMove", false)
		change_state("JumpState")
	#elif Input.is_action_just_pressed("jump") and !player.is_on_floor() and player.coyote_jump:	# TODO: das ist unnötig da du nur einen frame keinen boden hast und dann im fall state bist
		#change_state("JumpState")
	#elif Input.is_action_just_pressed("jump") and player.jump_count > 0:	# TODO: ist nie true da im enter der jump counter zurückgesetzt wird 
		#change_state("JumpState")
	#elif Input.is_action_pressed("jump") and  player.jump_buffer: # TODO sollte Input.is_action_pressed("jump") sein
		#change_state("JumpState")
	elif !player.is_on_floor():
		Debug.print_value("FallFromMove", true)
		player.jump_count -= 1
		change_state("FallState")
	elif inputX == 0:
		change_state("Idle")
#	----------Wall Walk ----------------------------
	if player.rc_right():
		change_state("WallRightState")
	elif player.rc_left():
		change_state("WallLeftState")
	elif player.rc_up():					#TODO: Kann das aus dem lauf passieren? 
		change_state("CeelingState")
