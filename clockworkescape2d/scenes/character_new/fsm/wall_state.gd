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
var timer : Timer 
var is_player_moving : bool = false
var dir : float = 0.0
var movement_timer : Timer
var tangent_coef : int = 1

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	player.velocity = Vector2.ZERO
	player.gravity = Vector2.ZERO
	is_player_moving = false
	player.update_animation(player.animations.IDLE)
	dir = 0.0

	check_direction()
	#if !is_player_moving:
		#movement_timer = Timer.new()
		#movement_timer.wait_time = 0.3
		#movement_timer.one_shot = true
		#movement_timer.timeout.connect(_on_player_move_timer_timeout)
		#add_child(movement_timer)
		#movement_timer.start()
		
func Physics_Update(_delta):
	var col_dir : Vector2 = Vector2.ZERO
	var tang : Vector2 = Vector2.ZERO
		
	Debug.print_value("Player on floor:", player.is_on_floor())	
	Debug.print_value("Player rc DOWN:", player.rc_down())	
	Debug.print_value("Is_Player_moving:", is_player_moving)
	#if movement_timer != null and movement_timer.time_left > 0:
	if !is_player_moving:
		check_direction()
	else:
		# calculate next point
		if player.shape_cast_2d.is_colliding():
			col_dir = (player.shape_cast_2d.get_collision_point(0) - player.global_position).normalized()
		else:
			col_dir = Vector2.ZERO
		# move 
		if dir:
			tang = Vector2(col_dir.y, -col_dir.x) * tangent_coef
			player.velocity =  tang * dir * player.max_speed + col_dir * 20
			draw_debug_line(tang * dir * player.max_speed + col_dir * 20)

		if Input.is_action_just_pressed("jump"):
			is_player_moving = false
			change_state("JumpState")
		
		elif not Input.is_action_pressed("left") and \
				not Input.is_action_pressed("right") and \
				not Input.is_action_pressed("up") and \
				not Input.is_action_pressed("down"):
			player.can_grab = false
			player.switch_ray_casts_off()
			change_state("FallState")
		
		#if player.velocity.y > player.max_speed / 2:
		#	print("idle from wall")
		#	change_state("IdleState")
			
		#if player.rc_not_colliding():
			#print("Switch to idle")
			#change_state("IdleState")
		Debug.print_value("Current dir: ", dir)
		#Update animation
		if dir != 0:
			if dir > 0:
				player.update_animation(player.animations.RUN_RIGHT)
			elif dir < 0:
				player.update_animation(player.animations.RUN_LEFT)
		else:
			player.update_animation(player.animations.IDLE)

func _on_player_move_timer_timeout():
	if !is_player_moving:
		if player.rc_left():
			player.move_player_x(1)
		elif player.rc_right():
			player.move_player_x(-1)
			
		player.switch_ray_casts_off()
		change_state("FallState")
		movement_timer.queue_free()
		
func check_direction():
	if player.rc_left() or player.rc_right():
		#if !is_player_moving:
		dir = Input.get_axis("up", "down")
	elif player.rc_up() or player.rc_down():
		#if !is_player_moving:
		dir = Input.get_axis("left", "right")
	if player.rc_right() or player.rc_up():
		tangent_coef = -1
	elif player.rc_left() or player.rc_down():
		tangent_coef = 1
	if dir != 0.0:
		is_player_moving = true
		
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
		
func Exit():
	is_player_moving = false
	Debug.print_value("Is_Player_moving:", is_player_moving)


func draw_debug_line(target: Vector2):
	player.line_2d.clear_points()
	player.line_2d.add_point(player.global_position)
	player.line_2d.add_point(player.global_position + target)
