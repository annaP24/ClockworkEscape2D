extends StaticBody2D

var colors = [Color("3133ff")]
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.collected_objects += 1
		queue_free()
