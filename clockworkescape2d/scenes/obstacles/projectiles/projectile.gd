extends StaticBody2D
class_name Projectile

var speed : float = 2.0
var current_direction : Vector2 = Vector2.ZERO
var rotation_angle : float = 100.0

func _process(_delta: float) -> void:
	pass

func _on_damage_area_body_entered(_body: Node2D) -> void:
	pass
