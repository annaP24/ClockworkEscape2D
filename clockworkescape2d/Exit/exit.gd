extends Node2D

## Signals
signal player_exited


## Optional: set to true if exit should only work after calling activate()
@export var requires_activation: bool = false

## Node refs
@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var embers: CPUParticles2D = $ExitEmbers
@onready var sparks: CPUParticles2D = $ExitSparks

var _is_active := true

func _ready():
	randomize()
	_is_active = not requires_activation
	area.body_entered.connect(_on_body_entered)
	_start_pulse()
	embers.emitting = true
	_burst_loop()

func _start_pulse():
	# Soft breathing glow on the icon
	sprite.self_modulate = Color(1, 1, 1, 1)
	var tw := create_tween().set_loops()
	tw.tween_property(sprite, "self_modulate", Color(1.4, 1.2, 1.0, 1.0), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(sprite, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _burst_loop() -> void:
	await get_tree().process_frame
	while true:
		var wait := randf_range(0.8, 2.2)
		await get_tree().create_timer(wait).timeout
		sparks.emitting = true
		await get_tree().create_timer(0.06).timeout
		sparks.emitting = false

func activate():
	# Call this when all collectibles are taken
	_is_active = true
	var tw := create_tween()
	tw.tween_property(sprite, "self_modulate", Color(2.0, 1.6, 1.0, 1.0), 0.15)
	tw.tween_property(sprite, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 0.35)

func _on_body_entered(body: Node) -> void:
	if not _is_active:
		return
	if body.is_in_group("player") or body.name == "Player":
		emit_signal("player_exited")
