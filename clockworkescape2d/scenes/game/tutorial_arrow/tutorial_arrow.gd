extends Sprite2D
## Idle up/down bob so a tutorial arrow draws the player's attention.

func _ready() -> void:
	var base_position := position
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(self, "position", base_position - Vector2(0, 15), 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", base_position, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func hide_arrow() -> void:
	visible = false

func show_arrow() -> void:
	visible = true
