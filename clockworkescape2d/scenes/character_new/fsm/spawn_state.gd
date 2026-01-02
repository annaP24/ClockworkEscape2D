extends FsmNodeState

func Enter(player_node):
	super(player_node)
	player.jump_count = player.max_jump_count
	player.player_died_received = false
	player.wall_jump_count = player.wall_jump_count_max
	player.gravity = Vector2(0, player.fall_gravity)
	player.update_animation(player.animations.SPAWN)

func Physics_Update(_delta):
	change_state("IdleState")
