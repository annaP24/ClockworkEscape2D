extends FsmNodeState

var current_direction

func Enter(player_node):
	super(player_node)
	# Jump counter zuruecksetzen
	player.jump_count = player.max_jump_count
	#player.jump_button_released = true
	# Walljump counter zuruecksetzen
	player.wall_jump_count = player.wall_jump_count_max
	# Cojotejump zuruecksetzen
	player.can_coyote_jump = true

	#Update animation
	var inputX = Input.get_axis("left", "right")
	if inputX > 0:
		player.update_animation(player.animations.RUN_RIGHT)
	elif inputX < 0:
		player.update_animation(player.animations.RUN_LEFT)

	player.is_player_moving = true

func Physics_Update(delta):
	if not player.is_movable:
		return

	#Move player x-axis
	var inputX = Input.get_axis("left", "right")
	inputX = player.normalize_movement(inputX)
	player.move_player_x(inputX)

	# Move player y-axis

	#Apply gravity
	player.apply_gravity(player.fall_gravity, delta)

	player.move_and_slide()
	#Update animation
	if inputX > 0:
		player.update_animation(player.animations.RUN_RIGHT)
	elif inputX < 0:
		player.update_animation(player.animations.RUN_LEFT)

	# cojote timer start
	if not player.is_on_floor():
		player.coyote_timer.start(player.coyote_timeout)

	#Change states
	if Input.is_action_pressed("jump") and player.jump_buffer:
		change_state("JumpState")
	elif Input.is_action_just_pressed("jump"):
		change_state("JumpState")
	elif !player.is_on_floor():
		player.jump_count -= 1
		player.set_can_grab(false)
		change_state("FallState")
	elif inputX == 0:
		change_state("IdleState")
	elif player.get_walkable_wall_side() == player.WallSide.DOWN: # and (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		change_state("WallContactState")
	elif player.get_walkable_wall_side() == player.WallSide.UP: # and (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		change_state("WallContactState")
	elif player.get_walkable_wall_side() == player.WallSide.LEFT and Input.is_action_pressed("left"):
		change_state("IdleState")
	elif player.get_walkable_wall_side() == player.WallSide.RIGHT and Input.is_action_pressed("right"):
		change_state("IdleState")
