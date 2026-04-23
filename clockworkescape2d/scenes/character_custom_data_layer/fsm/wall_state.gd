extends FsmNodeState

enum RollDirection {CW = 1, CCW = -1}

var roll_direction : RollDirection = RollDirection.CW
var tangent_coef : int = 30

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	player.can_wall_coyote_jump = true
	player.wall_jump_coyote_timer.start(player.wall_coyote_timeout)
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
	if player.get_collision_points().size() > 0:
		col_dir = (player.get_collision_points()[0] - player.global_position).normalized()
	else:
		col_dir = Vector2.ZERO
	# Tangente berechnen
	var tang = Vector2(col_dir.y, -col_dir.x)
	# ensure tangent aligns with player intent
	#if tang.dot(player.velocity) < 0:
		#tang = -tang
	# move player
	player.velocity =  tang * -roll_direction * player.move_speed #+ col_dir * tangent_coef # TODO evtl. delta hinzufügen
	#player.velocity =  tang * -roll_direction * player.move_speed + col_dir * tangent_coef # TODO evtl. delta hinzufügen

	player.move_and_slide()

	if Input.is_action_just_pressed("jump"):
		player.set_can_grab(false)
		change_state("JumpState")
	elif not Input.is_action_pressed("left") and \
			not Input.is_action_pressed("right") and \
			not Input.is_action_pressed("up") and \
			not Input.is_action_pressed("down"):
		player.set_can_grab(false)
		player.jump_count = 0
		change_state("FallState")
	elif player.get_walkable_wall_side() == player.WallSide.NONE:
		player.set_can_grab(false)
		player.jump_count = 0
		change_state("FallState")
	elif player.get_walkable_wall_side() == player.WallSide.NONE:
		change_state("RunState")
		
func get_average_wall_normal() -> Vector2:
	var points = player.get_collision_points()
	if points.is_empty():
		return Vector2.ZERO
		
	var normal : Vector2 = Vector2.ZERO
	for p in points:
		normal += (player.global_position - p).normalized()
	
	return normal.normalized()

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
