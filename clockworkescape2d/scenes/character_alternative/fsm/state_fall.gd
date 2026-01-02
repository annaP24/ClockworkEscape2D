extends FsmNodeState

func Enter(player_node):
	super(player_node)

func Physics_Update(delta):
	if not player.is_movable:
		return
		
	#Move player x-axis
	var inputX = Input.get_axis("left", "right")
	inputX = player.normalize_movement(inputX)
	player.move_player_x(inputX, player.max_speed)

	# Move player y-axis

	#Apply gravity
	if player.velocity.y < 0: # Still Rising
		player.apply_gravity(player.fall_gravity * player.gravity_coef, delta)
	if player.velocity.y >= 0: #Falling
		player.apply_gravity(player.fall_gravity, delta)

	player.move_and_slide()
	
	# jump buffer start
	if Input.is_action_just_pressed("jump"):
		player.jump_buffer = true
		player.jump_buffer_timer.start(player.jump_buffer_timeout)
	
	
	# Double jump
	if Input.is_action_just_pressed("jump") and player.jump_count > 0:
		change_state("JumpState")
	# Normal Wall jump
	elif Input.is_action_just_pressed("jump") and player.get_wall_collision() and player.wall_jump_count > 0:
		player.wall_jump_count = 0
		change_state("JumpState")
	elif Input.is_action_just_pressed("jump") and player.can_coyote_jump:
		change_state("JumpState")
	elif player.is_on_floor():
		squash_on_land()
		change_state("IdleState")
	elif player.rc_right() or player.rc_left() or player.rc_up():
		if player.get_can_grab():
			change_state("WallContactState")


func squash_on_land():
	var tween = get_parent().create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	# 1. Squash down: scale X up (1.3) and Y down (0.7)
	tween.tween_property(player.squash_marker, "scale", Vector2(1.3, 0.7), 0.1) #.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# 2. Return to normal: scale back to (1.0, 1.0)
	tween.tween_property(player.squash_marker, "scale", Vector2(1.0, 1.0), 0.2) #.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
