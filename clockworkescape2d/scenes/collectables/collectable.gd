extends StaticBody2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		AudioManager.play_sfx("collected")
		body.update_collectables_number()
		queue_free()
