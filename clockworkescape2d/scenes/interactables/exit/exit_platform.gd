extends Node2D

# --------Variables-----------------------------------------------------------
@export var move_range : float = 3*64.0
@onready var sprite_arrow: Sprite2D = $SpriteArrow
@onready var activationimer: Timer = $ActivationTimer
@onready var platform: AnimatableBody2D = $Platform
@onready var end_timer: Timer = $EndTimer

enum State {MOVE_UP, MOVE_DOWN, IDLE}
const POSITION_THRESHOLD : float = 2.0

var activation_timeout : float = 0.5
var end_timeout : float = 0.3
var start_arrow_pos : Vector2 = Vector2.ZERO
var move_speed : float = 70
var current_state : State = State.IDLE
var is_player_on_platform : bool = false
var platform_init_pos : Vector2 = Vector2.ZERO
var current_target : Vector2 = Vector2.ZERO
var end_position : Vector2 = Vector2.ZERO
var init_position : Vector2 = Vector2.ZERO
var player : PlayerFsmCustomDataLayer

# --------Functions-----------------------------------------------------------
func _ready() -> void:
	start_arrow_pos = sprite_arrow.position
	init_position = platform.position
	var offset : Vector2 = Vector2.ZERO

	offset = Vector2(0, move_range * -1)

	end_position = init_position + offset
	current_target = end_position
	_move_arrow()

func _physics_process(delta: float) -> void:
	match current_state:
		State.MOVE_UP:
			current_target = end_position
			_move_platform(delta)
		State.MOVE_DOWN:
			current_target = init_position
			_move_platform(delta)

func _move_arrow():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite_arrow, "position", start_arrow_pos - Vector2(0,15), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite_arrow, "position", start_arrow_pos, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _move_platform(delta : float):
	platform.position = platform.position.move_toward(current_target, move_speed * delta)
	if current_state == State.MOVE_UP:
		sprite_arrow.visible = false
		if platform.position.distance_to(end_position) < POSITION_THRESHOLD and player:
			player.turn_off_light()
			current_state = State.IDLE
			end_timer.start(end_timeout)

	if current_state == State.MOVE_DOWN:
		if platform.position.distance_to(init_position) < POSITION_THRESHOLD:
			sprite_arrow.visible = true
			current_state = State.IDLE

# --------Signals-------------------------------------------------------------
func _on_exit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		is_player_on_platform = true
		activationimer.start(activation_timeout)

func _on_activation_timer_timeout() -> void:
	if player:
		player.set_collision_mask_value(1, false)
		current_state = State.MOVE_UP

func _on_exit_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player.set_collision_mask_value(1, true)
		player.turn_on_light()
		player = null
		is_player_on_platform = false
		current_state = State.MOVE_DOWN


func _on_end_timer_timeout() -> void:
	if is_player_on_platform:
		EventBus.exit_level_finished.emit()
