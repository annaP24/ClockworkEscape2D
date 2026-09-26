extends Node2D

func _ready() -> void:
	var base_position := position
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(self, "position", base_position - Vector2(0, 8), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", base_position, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is PlayerFsmCustomDataLayer:
        EventBus.key_collected.emit()
		queue_free()
