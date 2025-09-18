extends FsmNodeState
var is_moving_wall : bool = false
var moving_wall_speed : float = 0.0
var wall_moving_direction : Vector2 = Vector2.ZERO
var timer : Timer 
var is_player_moving : bool = false
var timer_timeout 

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	
func Physics_Update(_delta):
	#Move player x-axis
	player.velocity.x = 0
	#Move player y-axis
	player.gravity = Vector2(0, 0) #-player.fall_gravity
	var inputY =  Input.get_axis("up", "down")
	
	if player.rc_left():
		var wall = player.get_collider_left()
		check_if_moving_wall(wall)

	player.move_player_y(inputY)
		
	#Change states	
	if Input.is_action_just_pressed("jump"):
		Debug.print_value("IsOnWall", player.is_on_wall())
		if player.rc_left():# and Input.is_action_pressed("right"):
			player.switch_rc_left_off()
			player.velocity.x = 1 * player.max_speed * GameManager.wall_jump_coaf * 100
			change_state("JumpState")
		else:
			player.switch_rc_left_off()
			player.move_player_x(1)
			change_state("FallFromWallState")
	elif Input.is_action_just_pressed("right"):
		if player.rc_up():
			player.switch_rc_left_off()
			change_state("CeelingState")
	elif !player.rc_left():
		player.switch_rc_left_off()
		if player.rc_down() and Input.is_action_pressed("left"):
			change_state("RunState")
		elif player.rc_up() and Input.is_action_pressed("left"):
			change_state("CeelingState")
		else:	
			player.switch_rc_left_off()
			player.move_player_x(1)
			change_state("FallFromWallState")
		
	#Animations
	if player.velocity.y > 0:
		player.update_animation(player.animations.RUN_RIGHT)
	elif player.velocity.y < 0:
		player.update_animation(player.animations.RUN_LEFT)
	else:
		if is_moving_wall:
			player.move_player_x(int(wall_moving_direction.x), moving_wall_speed)
			player.move_player_y(int(wall_moving_direction.y), moving_wall_speed)
		player.update_animation(player.animations.IDLE)
		
func _on_player_move_timer_timeout():
	player.switch_rc_left_off()
	player.move_player_x(1)
	change_state("FallFromWallState")
	timer.queue_free()
	
func check_if_moving_wall(wall):
	if wall.has_method("get_is_moving") and wall.get_is_moving():
		is_moving_wall = true
		moving_wall_speed = wall.get_parent().move_speed
		if wall.get_parent().is_move_vertical:
			if wall.get_parent().move_up:
				wall_moving_direction = Vector2(0,1)
			else:
				wall_moving_direction = Vector2(0,-1)
		else:
			if wall.get_parent().move_right:
				wall_moving_direction = Vector2(1,0)
			else:
				wall_moving_direction = Vector2(-1,0)
	else:
		is_moving_wall = false
