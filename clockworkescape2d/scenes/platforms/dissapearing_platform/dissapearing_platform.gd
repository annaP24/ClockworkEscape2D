
@tool
extends StaticBody2D
@export var is_disappearing : bool = false
@export var crack_timeout : float = 0.3
@export var dissapear_timeout : float = 0.5
@export var appear_timeout : float = 3.0
@export var is_easy_mode : bool = true
@onready var dissapear_timer: Timer = $DissapearTimer
@onready var appear_timer: Timer = $AppearTimer
@onready var crack_timer1: Timer = $CrackTimer1
@onready var crack_timer2: Timer = $CrackTimer2

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $Collision
@onready var detection_collision: CollisionShape2D = $DetectionArea/DetectionCollision
@onready var sprite_2d: Sprite2D = $Sprite2D

var texture1 = load("res://scenes/platforms/dissapearing_platform/assets/platform_dissapearing0.png")
var texture2 = load("res://scenes/platforms/dissapearing_platform/assets/platform_dissapearing1.png")
var texture3 = load("res://scenes/platforms/dissapearing_platform/assets/platform_dissapearing2.png")
var is_platform_visible : bool = true

func _ready() -> void:
	if is_disappearing:
		sprite_2d.texture = texture1
	else:
		sprite_2d.texture = load("res://scenes/platforms/small_platform/assets/platform.png")

func _on_detection_area_body_entered(body: Node2D) -> void:
	if is_disappearing:
		if body.is_in_group("player"):
			if body.global_position.y < global_position.y and is_easy_mode:
				# Character is above platform → enable collision
				crack_timer1.start(crack_timeout)
			elif !is_easy_mode:
				crack_timer1.start(crack_timeout)


func _on_crack_timer_1_timeout() -> void:
	print("timer1_timeout")
	sprite_2d.texture = texture2
	crack_timer2.start(crack_timeout)

func _on_crack_timer_2_timeout() -> void:
	print("timer2_timeout")
	sprite_2d.texture = texture3
	dissapear_timer.start(dissapear_timeout)

func _on_dissapear_timer_timeout() -> void:
	print("dissapear timer_timeout")
	animation_player.play("dissapear")
	is_platform_visible = false

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	print("animation finished")

	if !is_platform_visible:
		collision.disabled = true
		detection_collision.disabled = true
		appear_timer.start(appear_timeout)
	else:
		collision.disabled = false
		detection_collision.disabled = false
		sprite_2d.texture = texture1
		#is_platform_visible = true
func _on_appear_timer_timeout() -> void:
	#collision.disabled = false
	#detection_collision.disabled = false
	is_platform_visible = true
	#sprite_2d.texture = texture1
	animation_player.play("appear")
