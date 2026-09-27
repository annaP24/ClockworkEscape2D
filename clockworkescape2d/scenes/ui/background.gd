extends Node2D
class_name Background
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_running : bool = false
func rotate_gears():
	is_running = true
	animation_player.play("rotate")

func stop_gears():
	is_running = false
	animation_player.stop()

func is_background_running() -> bool:
	return is_running