extends StaticBody2D

## Emitted right before this collectable is removed, so listeners can react to which one was picked up.
signal collected

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		AudioManager.play_sfx("collected")
		if body.has_method("update_collectables_number"):
			body.update_collectables_number()
		collected.emit()
		queue_free()
