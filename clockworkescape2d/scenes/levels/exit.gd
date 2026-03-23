extends StaticBody2D

signal level_finished

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var sparks: CPUParticles2D = $ExitSparks
@onready var marker_2d: Marker2D = $Marker2D
@onready var timer: Timer = $Timer
var timer_timeout : float = 1.0

func _ready():
	randomize()
	#activate()
	start_pulsing()
	#burst_loop()

func start_pulsing():
	# Soft breathing glow on the icon
	sprite.self_modulate = Color(1, 1, 1, 1)
	var tw := create_tween().set_loops()
	tw.tween_property(sprite, "self_modulate", Color(1.4, 1.2, 1.0, 1.0), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(sprite, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func burst_loop() -> void:
	await get_tree().process_frame
	while true:
		var wait := randf_range(5.0, 10.0)
		await get_tree().create_timer(wait).timeout
		sparks.emitting = true
		await get_tree().create_timer(0.06).timeout
		sparks.emitting = false

func activate():
	# Call this when all collectibles are taken
	var tw := create_tween()
	tw.tween_property(sprite, "self_modulate", Color(2.0, 1.6, 1.0, 1.0), 0.15)
	tw.tween_property(sprite, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 0.35)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#ToDO: pull player
		var tween = get_parent().create_tween()
		tween.tween_property(body, "global_position", marker_2d.global_position, 1.0)
		await tween.finished
		body.process_mode = Node.PROCESS_MODE_DISABLED
		timer.start(timer_timeout)


func _on_timer_timeout() -> void:
	level_finished.emit()
