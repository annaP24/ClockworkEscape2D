extends FsmNodeState
## Horizontal dash without gravity. Reachable from Idle, Run, Jump and Fall.
## Exits to IdleState (floor), WallContactState (wall) or FallState (air).

var dash_direction : float = 1.0
var time_left : float = 0.0

func Enter(player_node):
	super(player_node)
	player.dash_available = false
	player.dash_cooldown_left = player.dash_cooldown
	player.set_can_grab(true)

	var input_x = get_input_x()
	dash_direction = input_x if input_x != 0.0 else player.facing_direction
	player.facing_direction = dash_direction
	time_left = player.dash_duration

	player.velocity = Vector2(player.dash_speed * dash_direction, 0.0)

func Exit():
	# Limit leftover dash speed so momentum doesn't carry into the next state
	player.velocity.x = clamp(player.velocity.x, -player.move_speed, player.move_speed)

func Physics_Update(delta):
	if not player.is_movable:
		return

	time_left -= delta
	player.velocity = Vector2(player.dash_speed * dash_direction, 0.0)
	player.move_and_slide()

	if player.is_on_wall() and player.get_can_grab() and \
			(player.get_walkable_wall_side() != player.WallSide.NONE or \
			player.get_movable_wall_side() != player.WallSide.NONE):
		change_state("WallContactState")
	elif time_left <= 0.0 or player.is_on_wall():
		if player.is_on_floor():
			change_state("IdleState")
		else:
			change_state("FallState")
