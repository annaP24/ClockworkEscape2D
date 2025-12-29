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

	# Double jump
	if Input.is_action_just_pressed("jump"):
		# If double jump available jump again
		if player.jump_count > 0:
			change_state("JumpState")
		# Wall jump
		elif player.get_wall_collision() and player.wall_jump_count > 0:
			player.wall_jump_count = 0
			change_state("JumpState")
		# jump buffer start
		player.jump_buffer = true
		player.jump_buffer_timer.start(player.jump_buffer_timeout)

	elif Input.is_action_just_pressed("jump") and player.coyote_jump:
		change_state("JumpState")
	elif player.is_on_floor():
		squash_on_land()
		change_state("IdleState")
	elif player.rc_right() or player.rc_left() or player.rc_up() or player.get_wall_collision():
		if player.is_on_floor():
			change_state("StateIdle")
		else:
			if player.get_can_grab():
				change_state("WallState")

func squash_on_land():
	var tween = get_parent().create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	# 1. Squash down: scale X up (1.3) and Y down (0.7)
	tween.tween_property(player.squash_marker, "scale", Vector2(1.3, 0.7), 0.1) #.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# 2. Return to normal: scale back to (1.0, 1.0)
	tween.tween_property(player.squash_marker, "scale", Vector2(1.0, 1.0), 0.2) #.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
