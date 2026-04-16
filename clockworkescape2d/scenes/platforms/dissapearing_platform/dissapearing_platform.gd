extends StaticBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var detection_collision: CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var timeout_timer: Timer = %TimeoutTimer

var timeout : float = 0.3
var is_visible : bool = true

func _ready() -> void:
	collision.disabled = false
	sprite_2d.texture = load("res://scenes/platforms/dissapearing_platform/assets/breakable_platform.png")


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.global_position.y < global_position.y:
			# Character is above platform → enable collision
			timeout_timer.start(timeout)
			#play_crack_sound()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "dissolve":
		collision.disabled = true
		detection_collision.disabled = true
		is_visible = false
		timeout_timer.start(timeout)
	elif anim_name == "appear":
		is_visible = true
		collision.disabled = false
		detection_collision.disabled = false

func _on_appear_timer_timeout() -> void:
	if is_visible:
		animation_player.play("dissolve")
	else:
		animation_player.play("appear")
