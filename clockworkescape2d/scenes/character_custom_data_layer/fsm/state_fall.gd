extends FsmNodeState

func Enter(player_node):
	super(player_node)
	player.set_can_grab(true)

func Physics_Update(delta):
	if not player.is_movable:
		return

	player.move_player_x(get_input_x())

	if player.velocity.y < 0: # Still rising
		player.apply_gravity(player.fall_gravity * player.gravity_coef, delta)
	else:
		player.apply_gravity(player.fall_gravity, delta)

	player.get_wall_direction()
	player.move_and_slide()

	var jump_pressed = Input.is_action_just_pressed("jump")
	if jump_pressed:
		player.jump_buffer = true
		player.jump_buffer_timer.start(player.jump_buffer_timeout)

	if try_dash():
		return
	elif jump_pressed and player.can_wall_coyote_jump and player.wall_jump_count > 0:
		player.wall_jump_count = 0
		player.jump_kind = player.JumpKind.WALL
		change_state("JumpState")
	elif jump_pressed and player.jump_count > 0:
		change_state("JumpState")
	elif jump_pressed and player.can_coyote_jump:
		change_state("JumpState")
	elif player.is_on_floor():
		squash_on_land()
		AudioManager.play_sfx("ground_reached")
		change_state("IdleState")
	elif player.get_can_grab() and (player.get_walkable_wall_side() != player.WallSide.NONE or \
			player.get_movable_wall_side() != player.WallSide.NONE):
		change_state("WallContactState")

func squash_on_land():
	var tween = get_parent().create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(player.squash_marker, "scale", Vector2(1.3, 0.7), 0.1)
	tween.tween_property(player.squash_marker, "scale", Vector2(1.0, 1.0), 0.2)
