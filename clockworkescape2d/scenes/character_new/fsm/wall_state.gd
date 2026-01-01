extends FsmNodeState
var direction : int = 0
var is_moving_wall : bool = false
var moving_wall_speed : float = 0.0
var wall_moving_direction : Vector2 = Vector2.ZERO
var is_player_moving : bool = false
var dir : float = 0.0
var movement_timer : Timer
var tangent_coef : int = 1
var wall_grab_timeout : float = 0.1
var wall_instance  = null
var player_last_position : Vector2 = Vector2.ZERO

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	player.velocity = Vector2.ZERO
	player.gravity = Vector2.ZERO
	is_player_moving = false
	dir = 0.0
	player.update_animation(player.animations.IDLE)

	wall_instance = player.get_wall_grab_collider()
	if wall_instance.has_method("is_platform_detection_area"):
		check_if_moving_wall(wall_instance)
	if !is_moving_wall:
		check_direction()
		if !is_player_moving:
			start_timer()


func start_timer():
	movement_timer = Timer.new()
	movement_timer.wait_time = wall_grab_timeout
	movement_timer.one_shot = true
	movement_timer.timeout.connect(_on_player_move_timer_timeout)
	add_child(movement_timer)
	movement_timer.start()

func Physics_Update(delta):
	if !is_moving_wall:
		#If player can't grab the walll return
		if !player.get_can_grab():
			return
		var col_dir : Vector2 = Vector2.ZERO
		var tang : Vector2 = Vector2.ZERO

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

			if Input.is_action_just_pressed("jump"):
				is_player_moving = false
				player.set_can_grab(false)
				change_state("JumpState")
			elif not Input.is_action_pressed("left") and \
					not Input.is_action_pressed("right") and \
					not Input.is_action_pressed("up") and \
					not Input.is_action_pressed("down"):
				if player.rc_down():
					is_player_moving = false
					change_state("IdleState")
				else:
					player.set_can_grab(false)
					change_state("FallState")
			elif player.rc_not_colliding() and !player.shape_cast_2d.is_colliding():
				player.set_can_grab(false)
				change_state("FallState")
			#Update animation
			if dir != 0:
				if dir > 0:
					player.update_animation(player.animations.RUN_RIGHT)
				elif dir < 0:
					player.update_animation(player.animations.RUN_LEFT)
			else:
				player.update_animation(player.animations.IDLE)
	else:
		get_wall_direction(wall_instance)
		player.move_player_position(moving_wall_speed * delta * wall_moving_direction)

		if Input.is_action_just_pressed("jump"):
			is_player_moving = false
			player.set_can_grab(false)
			change_state("JumpState")
		elif Input.is_action_just_pressed("left") or \
			Input.is_action_just_pressed("right") or \
			Input.is_action_just_pressed("down"):
			player.set_can_grab(false)
			change_state("FallState")

	if player.is_movable:
		player.move_and_slide()

func _on_player_move_timer_timeout():
	if !is_player_moving:
		if player.rc_down():
			is_player_moving = false
		else:
			player.set_can_grab(false)
			change_state("FallState")
			movement_timer.queue_free()

func check_direction():
	if Input.is_action_just_pressed("jump"):
		change_state("JumpState")

	if player.rc_left() or player.rc_right():
		dir = Input.get_axis("up", "down")
		dir = player.normalize_movement(dir)

	elif player.rc_up() or player.rc_down():
		dir = Input.get_axis("left", "right")
		dir = player.normalize_movement(dir)

	if player.rc_right() or player.rc_up():
		tangent_coef = -1
	elif player.rc_left() or player.rc_down():
		tangent_coef = 1
	if dir != 0.0:
		is_player_moving = true

func check_if_moving_wall(wall ):
	if wall != null:
		if wall.has_method("get_is_moving") and wall.get_is_moving():
			is_moving_wall = true
		else:
			is_moving_wall = false
	else:
		is_moving_wall = false

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

func draw_debug_line(target: Vector2):
	player.line_2d.clear_points()
	player.line_2d.add_point(player.global_position)
	player.line_2d.add_point(player.global_position + target)
