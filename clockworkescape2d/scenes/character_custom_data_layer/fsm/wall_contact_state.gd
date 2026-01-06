extends FsmNodeState

var falldown_time = 2

@onready var falldown_timer = $falldown_timer

func Enter(player_node):
	super(player_node)
	# Stoppe den Player
	player.velocity = Vector2.ZERO
	falldown_timer.start(falldown_time)

	player.update_animation(player.animations.IDLE)

func Physics_Update(_delta):
	if not player.is_movable:
		return

	#Move player x-axis
	var inputX = Input.get_axis("left", "right")
	inputX = player.normalize_movement(inputX)

	# Move player y-axis
	var inputY = Input.get_axis("up", "down")
	inputY = player.normalize_movement(inputY)

	#Apply gravity

	player.move_and_slide()
	#print(player.is_movable_wall())
	#var colliders = player.get_colliding_tile_type()

	if falldown_timer.is_stopped():
		player.set_can_grab(false)
		change_state("FallState")
	elif Input.is_action_just_pressed("jump"):
		player.set_can_grab(false)
		change_state("JumpState")
	elif Input.is_action_pressed("jump") and player.jump_buffer:
		player.set_can_grab(false)
		change_state("JumpState")
	elif player.get_walkable_wall_side() != player.WallSide.NONE and inputY != 0: # and player.is_normal_wall():
		change_state("WallState")
	elif player.get_walkable_wall_side() != player.WallSide.NONE and inputX != 0: # and player.is_normal_wall():
		change_state("WallState")

	#elif player.rc_right() and inputY != 0 and player.is_normal_wall():
		#change_state("WallState")
	#elif player.rc_left() and inputY != 0 and player.is_normal_wall():
		#change_state("WallState")
	#elif player.rc_up() and inputX != 0 and player.is_normal_wall():
		#change_state("WallState")
	#elif player.rc_down() and inputX != 0 and player.is_normal_wall():
		#change_state("WallState")
	elif player.rc_right()  and player.is_movable_wall():
		change_state("WallMovableState")
	elif player.rc_left()  and player.is_movable_wall():
		change_state("WallMovableState")
	elif player.rc_up()  and player.is_movable_wall():
		change_state("WallMovableState")
	elif player.rc_down()  and player.is_movable_wall():
		change_state("WallMovableState")
