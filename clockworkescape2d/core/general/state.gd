extends Node
class_name FsmNodeState

var player : PlayerFsmCustomDataLayer

func Enter(player_node):
	player = player_node


func Update(_delta):
	pass


func Physics_Update(_delta):
	pass


func Exit():
	pass

func get_input_x() -> float:
	return player.normalize_movement(Input.get_axis("left", "right"))

## Switches to DashState when dash was pressed and is allowed. Returns true on switch.
func try_dash() -> bool:
	if Input.is_action_just_pressed("dash") and player.can_start_dash():
		change_state("DashState")
		return true
	return false

func change_state(next_state):
	get_parent().change_state(self, next_state)
