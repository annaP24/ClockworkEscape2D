extends StaticBody2D

signal level_finished

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		level_finished.emit()
