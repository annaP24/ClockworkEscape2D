extends StaticBody2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shake_animation_player: AnimationPlayer = $ShakeAnimationPlayer
@onready var detection_collision: CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var appear_timer: Timer = $AppearTimer

var is_platform_visible : bool = true
var move_left : bool = true
var crack_timeout : float = 1.0
var appear_timeout : float = 2.0

func _ready() -> void:
	collision.disabled = false
	sprite_2d.texture = load("res://scenes/platforms/dissapearing_platform/assets/breakable_platform.png")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "break_light":
		pass
		#animation_player.play("break")

func low_crack_movement():
	if move_left:
		sprite_2d.position.x = sprite_2d.position.x - 5
	else:
		sprite_2d.position.x = sprite_2d.position.x + 5
	move_left = !move_left

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.global_position.y < global_position.y:
			# Character is above platform → enable collision
			animation_player.play("break_light")
			shake_animation_player.play("dissolve")
			#play_crack_sound()

func _on_shake_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "dissolve":
		collision.disabled = true
		detection_collision.disabled = true
		##ToDo- splash animation, parrticles
		appear_timer.start(appear_timeout)
	elif anim_name == "appear":
		collision.disabled = false
		detection_collision.disabled = false


func _on_appear_timer_timeout() -> void:
	#animation_player.play("appear")
	shake_animation_player.play("appear")
