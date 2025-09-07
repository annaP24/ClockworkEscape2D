extends FsmNodeState
var wall_jump_coef : int = 2
var is_moving_wall : bool = false
var moving_wall_speed : float = 0.0
var wall_moving_direction : Vector2 = Vector2.ZERO
var timer : Timer 
var is_player_moving : bool = false

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	
func Physics_Update(_delta):

	var inputY =  Input.get_axis("up", "down")
	
	#if player.rc_left():
	wall_left_process(inputY)
	#elif player.rc_right():
	wall_right_process(inputY)
			
func wall_left_process(inputY : float):
	#Move player x-axis
	player.velocity.x = 0
	#Move player y-axis
	
	if player.rc_left():
		player.gravity = Vector2(-player.fall_gravity, 0)
		if inputY == 0.0:
			if timer == null:
				timer = Timer.new()
				timer.connect("timeout", _on_player_move_timer_timeout)
				timer.one_shot = true
				add_child(timer)
				timer.start(0.3)
				is_player_moving = false
		else:
			is_player_moving = true
			if timer != null:
				timer.queue_free()
		var wall = player.get_collider_left()		
		check_if_moving_wall(wall)

	player.move_player_y(inputY)
		
	#Change states	
	if Input.is_action_just_pressed("right"):
		player.switch_rc_left_off()
		if player.rc_up():
			change_state("CeelingState")
		else:
			change_state("FallState")
	elif Input.is_action_just_pressed("jump"):
		player.switch_rc_left_off()
		player.velocity.x = 1 * player.max_speed * GameManager.wall_jump_coaf
		player.velocity.y = 1 * player.jump_gravity * GameManager.wall_jump_coaf
		change_state("JumpState")
	elif !player.rc_left():
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
			player.move_player_x(wall_moving_direction.x, moving_wall_speed)
			player.move_player_y(wall_moving_direction.y, moving_wall_speed)
		player.update_animation(player.animations.IDLE)
		

func wall_right_process(inputY : float):
	#Move player x-axis
	player.velocity.x = 0
	#Move player y-axis
	
	if player.rc_right():
		player.gravity	 = Vector2(player.fall_gravity, 0)
		if inputY == 0.0:
			if timer == null:
				timer = Timer.new()
				timer.connect("timeout", _on_player_move_timer_timeout)
				timer.one_shot = true
				add_child(timer)
				timer.start(0.3)
				is_player_moving = false
		else:
			is_player_moving = true
			if timer != null:
				timer.queue_free()
		var wall = player.get_collider_right()		
		check_if_moving_wall(wall)

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
	elif !player.rc_right():
		player.switch_rc_right_off()
		player.move_player_x(-1)
		change_state("FallFromWallState")
			
	#Animations
	if player.velocity.y > 0:
		player.update_animation(player.animations.RUN_LEFT)
	elif player.velocity.y < 0:
		player.update_animation(player.animations.RUN_RIGHT)
	else:
		if is_moving_wall:
			player.move_player_x(wall_moving_direction.x, moving_wall_speed)
			player.move_player_y(wall_moving_direction.y, moving_wall_speed)
		player.update_animation(player.animations.IDLE)
		
	
			
	
func _on_player_move_timer_timeout():
	if player.rc_left():
		player.switch_rc_left_off()
		player.move_player_x(1)
	elif player.rc_right():
		player.switch_rc_right_off()
		player.move_player_x(-1)
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
