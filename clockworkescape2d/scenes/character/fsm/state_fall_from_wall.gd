extends FsmNodeState
	
func Physics_Update(_delta):
	#player.move_player_x(-1)
	#Move player y-axis
	player.gravity = Vector2(0, player.fall_gravity)
	if player.is_on_floor():
		change_state("Idle")
