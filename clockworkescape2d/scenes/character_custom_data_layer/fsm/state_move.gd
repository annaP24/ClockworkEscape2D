extends FsmNodeState

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	player.wall_jump_count = player.wall_jump_count_max
	player.can_coyote_jump = true
	player.reset_dash()
	player.is_player_moving = true
	update_run_animation(get_input_x())

func Physics_Update(delta):
	if not player.is_movable:
		return

	var inputX = get_input_x()
	player.move_player_x(inputX)
	player.apply_gravity(player.fall_gravity, delta)
	player.move_and_slide()
	update_run_animation(inputX)

	if not player.is_on_floor():
		player.coyote_timer.start(player.coyote_timeout)

	var wall_side = player.get_walkable_wall_side()
	if Input.is_action_just_pressed("jump"):
		change_state("JumpState")
	elif !player.is_on_floor():
		player.jump_count -= 1
		player.set_can_grab(false)
		change_state("FallState")
	elif try_dash():
		return
	elif inputX == 0:
		change_state("IdleState")
	elif wall_side == player.WallSide.DOWN or wall_side == player.WallSide.UP:
		change_state("WallContactState")
	elif (wall_side == player.WallSide.LEFT and Input.is_action_pressed("left")) or \
			(wall_side == player.WallSide.RIGHT and Input.is_action_pressed("right")):
		change_state("IdleState")

func update_run_animation(inputX : float):
	if inputX > 0:
		player.update_animation(player.animations.RUN_RIGHT)
	elif inputX < 0:
		player.update_animation(player.animations.RUN_LEFT)
