extends Node
class_name FsmNodeState

var player

func Enter(player_node):
	player = player_node
	
	
func Update(_delta):
	pass
	
	
func Physics_Update(_delta):
	pass
	
	
func Exit():
	pass

func change_state(next_state):
	get_parent().change_state(self, next_state)
