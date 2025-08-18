extends FsmNodeState
var wall_jump_coef : int = 2
var direction : int = 0
var is_auto_wall : bool = false
var auto_wall_direction : int = 0
var auto_wall_speed : float = 0.0
var is_inverse_wall : bool = false
var is_moving_wall : bool = false
var moving_wall_speed : float = 0.0
var wall_moving_direction : Vector2 = Vector2.ZERO

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	if player.rc_right():
		var wall = player.get_collider_right()
		if wall.is_in_group("timed"):
			wall.start_timer()
			
func Physics_Update(_delta):
	player.velocity.x = 0
	player.gravity = Vector2(player.fall_gravity, 0)
	
	var inputY =  Input.get_axis("up", "down")
	if player.rc_right():
		var wall = player.get_collider_right()
		check_if_moving_wall(wall)
		if wall.is_in_group("inverse"):
			is_inverse_wall = true
		elif wall.is_in_group("auto"):
			is_inverse_wall = false
			auto_wall_direction = wall.direction_y
			auto_wall_speed = wall.player_speed
			if auto_wall_direction != 0:
				is_auto_wall = true
		else:
			is_inverse_wall = false
			is_auto_wall = false	
	if is_auto_wall:
		player.move_player_y(auto_wall_direction, auto_wall_speed)
	elif is_inverse_wall:
		player.move_player_y(-1*inputY)
	else:
		player.move_player_y(inputY)
		
	#Change states	
	if Input.is_action_just_pressed("left"):
		player.switch_rc_right_off()
		if player.rc_up():
			change_state("CeelingState")
		else:
			change_state("FallState")
	elif Input.is_action_just_pressed("jump"):
		player.switch_rc_right_off()
		player.velocity.x = -1 * player.max_speed * GameManager.wall_jump_coaf
		player.velocity.y = 1 * player.jump_gravity * GameManager.wall_jump_coaf
		change_state("JumpState")
	elif player.rc_right():
		var wall = player.get_collider_right()
		if wall.is_in_group("timed"):
			if !wall.get_is_walkable():
				player.switch_rc_right_off()
				player.move_player_x(-1)
				change_state("FallFromWallState")
		elif  wall.is_in_group("basic"):
			change_state("FallState")
	elif !player.rc_right():
		change_state("FallState")
		
	if player.velocity.y > 0:
		player.update_animation(player.animations.RUN_LEFT)
	elif player.velocity.y < 0:
		player.update_animation(player.animations.RUN_RIGHT)
	else:
		if is_moving_wall:
			player.move_player_x(wall_moving_direction.x, moving_wall_speed)
			player.move_player_y(wall_moving_direction.y, moving_wall_speed)
		player.update_animation(player.animations.IDLE)
		
func check_if_moving_wall(wall):
	if wall.has_method("get_is_moving") and wall.get_is_moving():
		is_moving_wall = true
		moving_wall_speed = wall.get_parent().move_speed
		if wall.get_parent().is_move_vertical:
			if wall.get_parent().move_up:
				wall_moving_direction = Vector2(0,-1)
			else:
				wall_moving_direction = Vector2(0,1)
		else:
			if wall.get_parent().move_right:
				wall_moving_direction = Vector2(1,0)
			else:
				wall_moving_direction = Vector2(-1,0)
	else:
		is_moving_wall = false
