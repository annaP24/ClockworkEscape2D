extends FsmNodeState

var is_moving_wall : bool = false
var moving_wall_speed : float = 0.0
var wall_moving_direction : Vector2 = Vector2.ZERO
var wall_instance = null

func Enter(player_node):
	super(player_node)

	wall_instance = player.get_movable_wall_collider()
	if wall_instance != null:
		check_if_moving_wall(wall_instance)

func Physics_Update(delta):
	if not player.is_movable:
		return

	get_wall_direction(wall_instance)
	player.move_player_position(moving_wall_speed * delta * wall_moving_direction)

	if Input.is_action_just_pressed("jump"):
		player.set_can_grab(false)
		change_state("JumpState")

func get_wall_direction(wall):
	moving_wall_speed = wall.get_parent().move_speed
	if wall.get_parent().is_move_vertical:
		if wall.get_parent().move_up:
			wall_moving_direction = Vector2(0, -1)
		else:
			wall_moving_direction = Vector2(0, 1)
	else:
		if wall.get_parent().move_right:
			wall_moving_direction = Vector2(1, 0)
		else:
			wall_moving_direction = Vector2(-1, 0)

func check_if_moving_wall(wall ):
	if wall != null:
		if wall.has_method("get_is_moving") and wall.get_is_moving():
			is_moving_wall = true
		else:
			is_moving_wall = false
	else:
		is_moving_wall = false
