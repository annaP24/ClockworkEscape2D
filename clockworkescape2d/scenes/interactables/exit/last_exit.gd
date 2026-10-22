extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		EventBus.last_exit_entered.emit()
