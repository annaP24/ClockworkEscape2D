extends FsmNodeState

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	player.wall_jump_count = player.wall_jump_count_max
	player.can_coyote_jump = true
	player.is_player_moving = false
	player.reset_dash()
	player.set_can_grab(true)
	player.update_animation(player.animations.IDLE)

func Physics_Update(_delta):
	if not player.is_movable:
		return
	var inputX = get_input_x()
	var wall_side = player.get_walkable_wall_side()

	player.move_player_x(0.0)
	player.move_and_slide()

	# Platform may disappear underneath the player while idle
	if !player.is_on_floor():
		player.jump_count = 0
		# Short window to still jump after the platform disappeared
		player.coyote_timer.start(player.idle_fall_coyote_timeout)
		change_state("FallState")
	elif try_dash():
		return
	elif Input.is_action_just_pressed("jump") or \
			(Input.is_action_pressed("jump") and player.jump_buffer):
		change_state("JumpState")
	elif inputX != 0 and wall_side == player.WallSide.NONE:
		change_state("RunState")
	elif Input.is_action_just_pressed("right") and wall_side == player.WallSide.LEFT:
		change_state("RunState")
	elif Input.is_action_just_pressed("left") and wall_side == player.WallSide.RIGHT:
		change_state("RunState")
	elif inputX != 0 and wall_side == player.WallSide.DOWN:
		change_state("WallContactState")
	elif (wall_side == player.WallSide.LEFT or wall_side == player.WallSide.RIGHT) and \
			Input.is_action_just_pressed("up"):
		change_state("WallContactState")
	elif wall_side == player.WallSide.DOWN and Input.is_action_just_pressed("down"):
		change_state("WallContactState")
