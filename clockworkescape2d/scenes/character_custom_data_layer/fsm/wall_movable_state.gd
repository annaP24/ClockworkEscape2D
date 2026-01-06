extends FsmNodeState

#var direction : int = 0
var is_moving_wall : bool = false
var moving_wall_speed : float = 0.0
var wall_moving_direction : Vector2 = Vector2.ZERO
#var is_player_moving : bool = false
#var dir : float = 0.0
#var movement_timer : Timer
#var tangent_coef : int = 1
#var wall_grab_timeout : float = 0.1
var wall_instance  = null
#var player_last_position : Vector2 = Vector2.ZERO

func Enter(player_node):
	super(player_node)

	wall_instance = player.get_wall_grab_collider()
	if wall_instance.has_method("is_platform_detection_area"):
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
