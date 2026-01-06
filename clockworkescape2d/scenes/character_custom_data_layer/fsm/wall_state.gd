extends FsmNodeState

enum RollDirection {CW = 1, CCW = -1}

var roll_direction : RollDirection = RollDirection.CW
var tangent_coef : int = 1


func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count

	# cw und ccw detection
	roll_direction = get_roll_direction()

	# Update animation
	if roll_direction < 0:
		player.update_animation(player.animations.RUN_RIGHT)
	else:
		player.update_animation(player.animations.RUN_LEFT)

func Physics_Update(_delta):
	if not player.is_movable:
		return

	# Normale zur Wand ermitteln
	var col_dir
	if player.get_is_shape_cast_colliding():
		col_dir = (player.get_collision_points()[0] - player.global_position).normalized()
	else:
		col_dir = Vector2.ZERO
	# Tangente berechnen
	var tang = Vector2(col_dir.y, -col_dir.x) * tangent_coef
	# player bewegen
	player.velocity =  tang * -roll_direction * player.max_speed + col_dir * 20 # TODO evtl. delta hinzufügen

	player.move_and_slide()
	var colliders = player.get_colliding_tile_type()

	if Input.is_action_just_pressed("jump"):
		player.set_can_grab(false)
		change_state("JumpState")
	elif not Input.is_action_pressed("left") and \
			not Input.is_action_pressed("right") and \
			not Input.is_action_pressed("up") and \
			not Input.is_action_pressed("down"):
		player.set_can_grab(false)
		change_state("FallState")
	#elif player.rc_not_colliding() and !player.get_is_shape_cast_colliding():
		#player.set_can_grab(false)
		#change_state("FallState")
	elif player.get_walkable_wall_side() == player.WallSide.NONE:
		player.set_can_grab(false)
		change_state("FallState")
	elif colliders.has("basic"):
		change_state("RunState")

func get_roll_direction() -> RollDirection:
	var y_axis = Input.get_axis("up", "down")
	var x_axis = Input.get_axis("left", "right")

	if player.get_walkable_wall_side() == player.WallSide.RIGHT and y_axis > 0:
		return RollDirection.CW
	if player.get_walkable_wall_side() == player.WallSide.RIGHT and y_axis < 0:
		return RollDirection.CCW

	if player.get_walkable_wall_side() == player.WallSide.LEFT and y_axis > 0:
		return RollDirection.CCW
	if player.get_walkable_wall_side() == player.WallSide.LEFT and y_axis < 0:
		return RollDirection.CW

	if player.get_walkable_wall_side() == player.WallSide.UP and x_axis > 0:
		return RollDirection.CW
	if player.get_walkable_wall_side() == player.WallSide.UP and x_axis < 0:
		return RollDirection.CCW

	if player.get_walkable_wall_side() == player.WallSide.DOWN and x_axis > 0:
		return RollDirection.CCW
	if player.get_walkable_wall_side() == player.WallSide.DOWN and x_axis < 0:
		return RollDirection.CW

	return RollDirection.CW
