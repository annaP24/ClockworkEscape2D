extends FsmNodeState

func Enter(player_node):
	super(player_node)
	player.velocity.y = player.jump_velocity
	player.jump_count -= 1
	player.jump_buffer = false
	player.can_coyote_jump = false

func Physics_Update(delta):
	if not player.is_movable:
		return

	player.move_player_x(get_input_x())
	player.apply_gravity(player.jump_gravity, delta)
	player.move_and_slide()

	if try_dash():
		return
	elif !Input.is_action_pressed("jump"):
		change_state("FallState")
	elif (Input.is_action_just_pressed("jump") or player.jump_buffer) and \
			player.last_wall_direction != player.WallSide.NONE and player.wall_jump_count > 0:
		player.wall_jump_count = 0
		change_state("JumpState")
	elif player.velocity.y >= 0:
		change_state("FallState")
