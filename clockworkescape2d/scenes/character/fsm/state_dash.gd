extends FsmNodeState
var inputX
func Enter(player_node):
	super(player_node)
	if player.can_dash:
		player.is_dashing = true
		player.can_dash = false
		inputX = Input.get_axis("left","right")
		player.velocity.x = player.dash_speed * inputX
		Debug.print_value("Dashspeed", player.velocity.x)
		Debug.print_value("DashDuration", player.dash_duration_timer.wait_time)
		player.dash_duration_timer.start(player.dash_duration)
		player.dash_timeout_timer.start(player.dash_timeout)
		
		
func Physics_Update(_delta):
	if !player.is_dashing:
		change_state("Idle")
		Debug.print_value("IsDashing", player.is_dashing)
	else:		
		player.velocity.x = player.dash_speed * inputX
		Debug.print_value("IsDashing", player.is_dashing)
		
