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
	
	if  player.rc_up() and Input.is_action_just_pressed("jump"):
		player.switch_rc_up_off()
		change_state("FallState")
		
	if  player.rc_right() and Input.is_action_pressed("right"):
		change_state("WallState")
	elif  player.rc_left() and Input.is_action_pressed("left"):
		change_state("WallState")	
	
	player.move_player_x(inputX)
			
	#if !player.rc_up():
		#if Input.is_action_pressed("up"):
			#change_state("RunState")
		#if player.rc_left() and Input.is_action_pressed("left"):
			#change_state("WallLeftState")
		#elif player.rc_right() and Input.is_action_pressed("right"):
			#change_state("WallRightState")
		#else:	
			#change_state("FallState")	
	#Update animations
	if player.velocity.x > 0:
		player.update_animation(player.animations.RUN_LEFT)
	elif player.velocity.x < 0:
		player.update_animation(player.animations.RUN_RIGHT)
	else:
		player.update_animation(player.animations.IDLE)
