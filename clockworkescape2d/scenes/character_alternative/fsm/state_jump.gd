extends FsmNodeState

func Enter(player_node):
	super(player_node)
	#player.jump_button_released = false
	#player.gravity = Vector2(0, player.jump_gravity)
	jump()
	player.jump_count -= 1
	player_node.switch_ray_casts_on()
	player.jump_buffer = false
	player.can_coyote_jump = false
	player.can_wall_coyote_jump = false
func jump():
	player.velocity.y = player.jump_velocity

func Physics_Update(delta):
	if not player.is_movable:
		return

	#Move player x-axis
	var inputX = Input.get_axis("left", "right")
	inputX = player.normalize_movement(inputX)
	player.move_player_x(inputX)

	# Move player y-axis

	#Apply gravity
	player.apply_gravity(player.jump_gravity, delta)

	player.move_and_slide()

	if !Input.is_action_pressed("jump"):
		#player.jump_button_released = true
		change_state("FallState")
	elif player.rc_up() and player.get_can_grab():
		change_state("WallContactState")
	#elif player.rc_right() and player.get_can_grab():
	#	change_state("WallContactState")
	#elif player.rc_left() and player.get_can_grab():
	# 	 change_state("WallContactState")
	#elif player.get_wall_collision():
		#change_state("WallState")
	elif player.velocity.y >= 0:
		change_state("FallState")
