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
	player.is_player_moving = false
	player.set_can_grab(true)
	player.switch_ray_casts_on()
	player.update_animation(player.animations.IDLE)

func Physics_Update(_delta):
	if not player.is_movable:
		return
	var inputX = Input.get_axis("left", "right")
	inputX = player.normalize_movement(inputX)
	var inputY = Input.get_axis("up", "down")
	inputY = player.normalize_movement(inputY)
	# Move player x-axis
	player.move_player_x(0.0)

	# Move player y-axis

	# Apply gravity

	player.move_and_slide()
	var colliders = player.get_colliding_tile_type()

	#Input reactions
	if !player.is_on_floor():
		change_state("FallState")
	elif Input.is_action_pressed("jump") and player.jump_buffer:
		change_state("JumpState")
	elif Input.is_action_just_pressed("jump"):
		change_state("JumpState")
	elif inputX != 0 and  \
	player.get_walkable_wall_side() == player.WallSide.NONE:
		change_state("RunState")
	elif Input.is_action_just_pressed("right") and \
	player.get_walkable_wall_side() == player.WallSide.LEFT:
		change_state("RunState")
	elif  Input.is_action_just_pressed("left") and \
	player.get_walkable_wall_side() == player.WallSide.RIGHT:
		change_state("RunState")
	elif inputX != 0 and \
	player.get_walkable_wall_side() == player.WallSide.DOWN:
		change_state("WallContactState")
	elif (player.get_walkable_wall_side() == player.WallSide.LEFT or \
	 player.get_walkable_wall_side() == player.WallSide.RIGHT) and \
	 Input.is_action_just_pressed("up"):
		change_state("WallContactState")
	elif player.get_walkable_wall_side() == player.WallSide.DOWN and \
	 Input.is_action_just_pressed("down"):
		change_state("WallContactState")
