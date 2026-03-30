extends Node2D
signal level_finished
# --------Variables-----------------------------------------------------------
@onready var sprite_arrow: Sprite2D = $SpriteArrow
@onready var activationimer: Timer = $ActivationTimer
@onready var platform: AnimatableBody2D = $Platform

var activation_timeout : float = 0.5
var start_arrow_pos : Vector2 = Vector2.ZERO
var move_range : float = 3*64.0
var delta_movement : float = 0.0
var move_speed : float = 70
var is_move_up : bool = false
var is_height_reached : bool = false
var is_player_on_platform : bool = false
var player : PlayerFsmCustomDataLayer
# --------Functions-----------------------------------------------------------
func _ready() -> void:
	start_arrow_pos = sprite_arrow.position
	_move_arrow()

func _physics_process(delta: float) -> void:
	if is_move_up:
		_move_platform_up(delta)

	if is_height_reached:# and is_player_on_platform:
		level_finished.emit()

func _move_arrow():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite_arrow, "position", start_arrow_pos - Vector2(0,15), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite_arrow, "position", start_arrow_pos, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _move_platform_up(delta : float):
	platform.position.y -= move_speed  * delta
	delta_movement += move_speed * delta
	if delta_movement >= move_range:
		is_move_up = false
		is_height_reached = true
		delta_movement = 0.0

# --------Signals-------------------------------------------------------------
func _on_exit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		is_player_on_platform = true
		sprite_arrow.visible = false
		activationimer.start(activation_timeout)


func _on_activation_timer_timeout() -> void:
	#Deactivate players layer 1 looking (to avoid collision with platforms)
	# Drive platform up
	#player.clamp_x_movement()
	player.set_collision_mask_value(1,false)
	is_move_up = true
	level_finished.emit()


func _on_exit_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		is_player_on_platform = false
