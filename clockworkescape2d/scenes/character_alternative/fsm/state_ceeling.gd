extends FsmNodeState
var direction : int = 0
var is_moving_wall : bool = false
var moving_wall_speed : float = 0.0
var wall_moving_direction : Vector2 = Vector2.ZERO

func Enter(player_node):
	super(player_node)
	if player.rc_up():
		var wall = player.get_collider_up()
		if wall.is_in_group("timed"):
			wall.start_timer()
			
func Physics_Update(_delta):
	player.velocity.y = -500
	player.gravity = Vector2(0, 0)
	
	var inputX = Input.get_axis("left", "right")
	if player.rc_up():
		var wall = player.get_collider_up()
		check_if_moving_wall(wall)
		
	if  player.rc_up() and Input.is_action_just_pressed("jump"):
		player.switch_rc_up_off()
		change_state("FallState")
		
	if  player.rc_right() and (Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		change_state("WallState")
	if  player.rc_left() and (Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		change_state("WallState")
	elif  player.rc_dl() and player.rc_left():
		change_state("WallState")
	
	if !player.rc_up():
		if player.rc_dl() or player.rc_dr():
			#change_state("EdgeState")
			var inputY = Input.get_axis("up", "down")
			player.move_player_y(inputY)
		else:	
			change_state("FallState")
			
	player.move_player_x(inputX)
	
	#Update animations
	if player.velocity.x > 0:
		player.update_animation(player.animations.RUN_LEFT)
	elif player.velocity.x < 0:
		player.update_animation(player.animations.RUN_RIGHT)
	else:
		if is_moving_wall:
			player.move_player_x(int(wall_moving_direction.x), moving_wall_speed)
			player.move_player_y(int(wall_moving_direction.y), moving_wall_speed)
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
