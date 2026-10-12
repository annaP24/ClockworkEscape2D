extends Sprite2D
## Idle bob so a tutorial arrow draws the player's attention.

@export var move_left_right: bool = false

func _ready() -> void:
	var base_position : Vector2 = position
	var bob_offset := Vector2(-15, 0) if move_left_right else Vector2(0, -15)
	# Bound to this node so the tween dies with it; a tree-owned looping tween on a freed target runs with zero duration and triggers "Infinite loop detected".
	var tween : Tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "position", base_position + bob_offset, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", base_position, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func hide_arrow() -> void:
	visible = false

func show_arrow() -> void:
	visible = true
