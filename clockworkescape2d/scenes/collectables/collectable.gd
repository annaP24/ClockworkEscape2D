extends StaticBody2D

## Emitted right before this collectable is removed, so listeners can react to which one was picked up.
signal collected

## Slot within the level (0-2), assigned by Level in tree order.
var index : int = -1

func _ready() -> void:
	add_to_group("collectable")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		AudioManager.play_sfx("collected")
		collected.emit()
		EventBus.collectables_changed.emit()
		queue_free()
