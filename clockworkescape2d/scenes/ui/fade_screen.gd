extends Node

signal fade_in_finished
signal fade_out_finished
signal transition_finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func fade_in():
	animation_player.play("fade_in")
	await animation_player.animation_finished

func fade_out():
	animation_player.play("fade_out")
	await animation_player.animation_finished

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		fade_in_finished.emit()
	if anim_name == "fade_out":
		fade_out_finished.emit()
	if anim_name == "fade":
		transition_finished.emit()
