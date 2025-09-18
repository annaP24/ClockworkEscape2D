extends FsmNodeState

func Enter(player_node):
	super(player_node)
	player.jump_button_released = false
	player.gravity = Vector2(0, player.jump_gravity)
	jump()
	player.jump_count -= 1
	
func jump():
	player.velocity.y = player.jump_velocity
	
func Physics_Update(_delta):
	#Move player
	var inputX = Input.get_axis("left", "right")
	player.move_player_x(inputX)
	
	if !Input.is_action_pressed("jump") :
		player.jump_button_released = true
		player.jump_buffer = false
		player.coyote_jump = false
		change_state("FallState")

#---------- Wall Walk ----------------------------
	if player.rc_up():
		var wall = player.get_collider_up()
		if !wall.is_in_group("basic"):
			change_state("CeelingState")
	elif player.rc_right():
		var wall = player.get_collider_right()
		if !wall.is_in_group("basic"):
			change_state("WallState")
	elif player.rc_left():
		var wall = player.get_collider_left()
		if !wall.is_in_group("basic"):
			change_state("WallState")
	elif player.is_on_wall():
		if player.wall_jump_count > 0:
			player.jump_count = player.max_jump_count
			player.wall_jump_count = 0
			if Input.is_action_just_pressed("jump"):
				change_state("JumpState")
	elif player.velocity.y >= 0:
		change_state("FallState") 
