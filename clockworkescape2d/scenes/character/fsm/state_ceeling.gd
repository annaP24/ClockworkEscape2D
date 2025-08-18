extends FsmNodeState
var direction : int = 0
var is_auto_wall : bool = false
var auto_wall_direction : int = 0
var auto_wall_speed : float = 0.0
var is_inverse_wall : bool = false

func Enter(player_node):
	super(player_node)
	if player.rc_up():
		var wall = player.get_collider_up()
		if wall.is_in_group("timed"):
			wall.start_timer()
			
func Physics_Update(_delta):
	player.velocity.y = 0
	player.gravity = Vector2(0, 0)
	
	var inputX = Input.get_axis("left", "right")
	#player.move_player_x(inputX)
	
	if Input.is_action_just_pressed("down"):
		player.switch_rc_up_off()
		if  player.rc_right():
			change_state("WallRightState")
		elif  player.rc_left():
			change_state("WallLeftState")
		else:
			change_state("FallState")
	elif player.rc_up():
		var wall = player.get_collider_up()
		if wall.is_in_group("timed"):
			is_auto_wall = false
			is_inverse_wall = false
			wall.start_timer()
			if !wall.get_is_walkable():
				player.switch_rc_up_off()
				player.move_player_y(-1)
				change_state("FallFromWallState")
	
		elif wall.is_in_group("inverse"):
			is_auto_wall = false
			is_inverse_wall = true
		elif wall.is_in_group("auto"):
			is_inverse_wall = false
			auto_wall_direction = wall.direction_x
			if auto_wall_direction != 0:
				is_auto_wall = true
				auto_wall_speed = wall.player_speed
		elif  wall.is_in_group("basic"):
			change_state("FallState")
	if is_auto_wall:
		player.move_player_x(auto_wall_direction, auto_wall_speed)
	elif is_inverse_wall:
		player.move_player_x(-1*inputX)
	else:
		player.move_player_x(inputX)
			
	if !player.rc_up():
		change_state("FallState")
	
	#Update animations
	if player.velocity.x > 0:
		player.update_animation(player.animations.RUN_LEFT)
	elif player.velocity.x < 0:
		player.update_animation(player.animations.RUN_RIGHT)
	else:
		player.update_animation(player.animations.IDLE)
