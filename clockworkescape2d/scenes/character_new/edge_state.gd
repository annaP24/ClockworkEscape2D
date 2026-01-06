extends FsmNodeState

func Enter(player_node : Character):
	player = player_node
	player.gravity = Vector2(0, 0)

func Physics_Update(_delta):
	if player.rc_dr() and Input.is_action_just_pressed("right"):
		change_state("CeelingState")
	elif player.rc_dr() and Input.is_action_just_pressed("up"):
		change_state("WallState")
	elif player.rc_dl() and Input.is_action_just_pressed("left"):
		change_state("CeelingState")
	elif player.rc_dl() and Input.is_action_just_pressed("up"):
		change_state("WallState")
	elif player.rc_ddl() and Input.is_action_just_pressed("left"):
		change_state("IdleState")
	elif player.rc_ddr() and Input.is_action_just_pressed("right"):
		change_state("IdleState")

	elif !player.rc_dl() and !player.rc_dr():
		change_state("FallState")
