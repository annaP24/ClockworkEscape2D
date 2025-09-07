extends StaticBody2D
@export var is_disappearing : bool = false
@export var dissapear_timeout : float = 0.5
@export var appear_timeout : float = 3.0
@onready var dissapear_timer: Timer = $DissapearTimer
@onready var appear_timer: Timer = $AppearTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $Collision
@onready var detection_collision: CollisionShape2D = $DetectionArea/DetectionCollision

var is_platform_visible : bool = true

func _ready() -> void:
	if is_disappearing:
		dissapear_timer.wait_time = dissapear_timeout

func _on_dissapear_timer_timeout() -> void:
	animation_player.play("dissapear")
	is_platform_visible = false
	#collision.disabled = true

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if !is_platform_visible:
		collision.disabled = true
		detection_collision.disabled = true
		appear_timer.start(appear_timeout)
	
func _on_detection_area_body_entered(body: Node2D) -> void:
	if is_disappearing:
		if body.is_in_group("player"):
			dissapear_timer.start(dissapear_timeout)

func _on_appear_timer_timeout() -> void:
	collision.disabled = false
	detection_collision.disabled = false
	is_platform_visible = true
	animation_player.play_backwards("dissapear")
