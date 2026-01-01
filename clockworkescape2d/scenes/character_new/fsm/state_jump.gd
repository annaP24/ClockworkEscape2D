extends FsmNodeState

func Enter(player_node):
	super(player_node)
	player.jump_button_released = false
	player.gravity = Vector2(0, player.jump_gravity)
	jump()
	player.jump_count -= 1
	player_node.switch_ray_casts_on()

func jump():
	player.velocity.y = player.jump_velocity

func Physics_Update(_delta):
	#Move player
	var inputX = Input.get_axis("left", "right")
	inputX = player.normalize_movement(inputX)

	player.move_player_x(inputX)

	if !Input.is_action_pressed("jump") :
		player.jump_button_released = true
		player.jump_buffer = false
		player.coyote_jump = false
		change_state("FallState")

#---------- Wall Walk ----------------------------
	if player.rc_up() and player.get_can_grab():
		change_state("WallState")
	elif player.rc_right() and player.get_can_grab():
		change_state("WallState")
	elif player.rc_left() and player.get_can_grab():
		change_state("WallState")
	#elif player.get_wall_collision():
		#change_state("WallState")

	elif player.velocity.y >= 0:
		change_state("FallState")
	if player.is_movable:
		player.move_and_slide()
