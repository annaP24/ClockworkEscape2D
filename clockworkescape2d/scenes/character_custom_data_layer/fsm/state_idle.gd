extends FsmNodeState

func Enter(player_node):
	super(player_node)
	# Jump counter zuruecksetzen
	player.jump_count = player.max_jump_count
	# Walljump counter zuruecksetzen
	player.wall_jump_count = player.wall_jump_count_max
	# Cojotejump zuruecksetzen
	player.can_coyote_jump = true
	player.is_player_moving = false
	player.set_can_grab(true)
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

	player.move_and_slide()
	#Input reactions
	#Case where dissapearing platform dissappears undeneath player while in idle
	if !player.is_on_floor():
		player.jump_count = 0
		# Start koyote timeot so the player has a short window of time to still jump after platform dissapears
		player.coyote_timer.start(player.idle_fall_coyote_timeout)
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
