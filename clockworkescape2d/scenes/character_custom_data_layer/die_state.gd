extends FsmNodeState

func Enter(player_node):
	player = player_node
	player.move_player_x(0)
	player.move_player_y(0)
	player.update_animation(player.animations.DIE)

