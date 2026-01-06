@tool
extends StaticBody2D
class_name Switch

signal is_active
signal is_not_active

@export var is_left_wind : bool = true
@onready var switch_sprite: Sprite2D = $Sprite2D
@onready var switch_sprite_small: Sprite2D = $Sprite2D2

var is_active_emitted : bool = false
var is_not_active_emitted : bool = true

var player : Character

func _process(_delta: float) -> void:
	if player:
		if player.is_player_moving:
			if !is_active_emitted:
				is_active.emit()
				is_active_emitted = true
				is_not_active_emitted = false
		elif !player.is_player_moving and !is_not_active_emitted:
			is_not_active_emitted = true
			is_active_emitted = false
			is_not_active.emit()
		# Switch rotation depending on wall
		if is_left_wind:
			switch_sprite.rotate(-25.0)
			switch_sprite_small.rotate(25.0)
		else:
			switch_sprite.rotate(25.0)
			switch_sprite_small.rotate(-25.0)
	else:
		if !is_not_active_emitted:
			is_not_active_emitted = true
			is_active_emitted = false
			is_not_active.emit()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
