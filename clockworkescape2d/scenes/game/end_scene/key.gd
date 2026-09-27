extends Node2D

@onready var detection_area: Area2D = $DetectionArea

var _idle_tween: Tween
var _target_player: Node2D
var _hover_offset: Vector2
var _hover_elapsed: float = 0.0
var _is_collected: bool = false

func _ready() -> void:
	var base_position : Vector2 = position
	_idle_tween = create_tween()
	_idle_tween.set_loops()
	_idle_tween.tween_property(self, "position", base_position - Vector2(0, 8), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_idle_tween.tween_property(self, "position", base_position, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _process(delta: float) -> void:
	if not _is_collected:
		return
	if not is_instance_valid(_target_player):
		queue_free()
		return

	_hover_elapsed += delta
	global_position = _target_player.global_position + _hover_offset + Vector2(0, sin(_hover_elapsed * TAU / 1.6) * 4)


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is PlayerFsmCustomDataLayer and not _is_collected:
		_is_collected = true
		_target_player = body
		_hover_offset = global_position - body.global_position
		_idle_tween.kill()
		scale = Vector2(0.08, 0.08)
		detection_area.set_deferred("monitoring", false)
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(self, "_hover_offset", Vector2(-30, -40), 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		EventBus.key_collected.emit()
