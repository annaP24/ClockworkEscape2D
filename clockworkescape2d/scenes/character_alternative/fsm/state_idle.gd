extends FsmNodeState

func Enter(player_node):
	super(player_node)
	# Jump counter zuruecksetzen
	player.jump_count = player.max_jump_count
	#player.jump_button_released = true
	# Walljump counter zuruecksetzen
	player.wall_jump_count = player.wall_jump_count_max
	# Cojotejump zuruecksetzen
	player.can_coyote_jump = true
	player.can_wall_coyote_jump = false
	player.is_player_moving = false
	player.set_can_grab(true)
	player.switch_ray_casts_on()
	player.update_animation(player.animations.IDLE)

func Physics_Update(_delta):
	if not player.is_movable:
		return

	# Move player x-axis
	player.move_player_x(0.0)

	# Move player y-axis

	# Apply gravity

	player.move_and_slide()

	#Input reactions
	if !player.is_on_floor():
		change_state("FallState")
	elif Input.is_action_pressed("jump") and player.jump_buffer:
		change_state("JumpState")
	elif Input.is_action_just_pressed("jump"):
		change_state("JumpState")
	elif player.rc_down():
		change_state("WallContactState")
	elif Input.is_action_pressed("right") and !player.rc_right():
		change_state("RunState")
	elif Input.is_action_pressed("left") and !player.rc_left():
		change_state("RunState")
	elif player.rc_left() and Input.is_action_pressed("up"):
		change_state("WallContactState")
	elif player.rc_right() and Input.is_action_pressed("up"):
		change_state("WallContactState")
