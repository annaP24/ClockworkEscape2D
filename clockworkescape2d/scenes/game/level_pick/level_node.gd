extends Area2D
class_name LevelNode
signal level_selected(level_id)


@export var level_id: int
@export var is_unlocked: bool = false
@export var neighbour_up : LevelNode
@export var neighbour_down : LevelNode
@onready var sprite_enabled: Sprite2D = %Sprite2D_Gear
@onready var sprite_disabled: Sprite2D = %Sprite2D_Disabled
@onready var sprite_2d_hover: Sprite2D = %Sprite2D_Hover
@onready var sprite_2d_pressed: Sprite2D = %Sprite2D_Pressed
@onready var sprite_2d_focused: Sprite2D = %Sprite2D_Focused

@onready var sprite: Node2D = $Sprite
@onready var label: Label = %Label
@onready var collectables_visual: CollectableVisual = $CollectablesVisual
var parent : LevelPick
var is_selected : bool = false
var init_scale : Vector2 = Vector2(1,1)

enum  ButtonState { IDLE, HOVER, PRESSED, FOCUSED, DISABLED }

var current_state : ButtonState = ButtonState.IDLE

func _ready():
	set_sprite_state(current_state)
	init_scale = sprite.scale
	collectables_visual.update_collected_count()

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if is_unlocked:
			trigger_button()
		else:
			_shake_locked_button()

func _shake_locked_button():
	var tween = get_tree().create_tween()
	#Shake the locked button diagonally: up-left, down-right, back to initial position
	var shake_offset = Vector2(-4, -4)
	var original_position = sprite.position
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "position", original_position + shake_offset, 0.08)
	tween.tween_property(sprite, "position", original_position - shake_offset, 0.12)
	tween.tween_property(sprite, "position", original_position, 0.1)

func trigger_button():
	AudioManager.play_sfx("click", 0.2)
	level_selected.emit(level_id)

func set_sprite_state(state: ButtonState):
	match state:
		ButtonState.IDLE:
			sprite_enabled.visible = true
			sprite_disabled.visible = false
			sprite_2d_hover.visible = false
			sprite_2d_pressed.visible = false
			sprite_2d_focused.visible = false
		ButtonState.HOVER:
			sprite_enabled.visible = false
			sprite_disabled.visible = false
			sprite_2d_hover.visible = true
			sprite_2d_pressed.visible = false
			sprite_2d_focused.visible = false
		ButtonState.PRESSED:
			sprite_enabled.visible = false
			sprite_disabled.visible = false
			sprite_2d_hover.visible = false
			sprite_2d_pressed.visible = true
			sprite_2d_focused.visible = false
		ButtonState.FOCUSED:
			sprite_enabled.visible = false
			sprite_disabled.visible = false
			sprite_2d_hover.visible = false
			sprite_2d_pressed.visible = false
			sprite_2d_focused.visible = true
		ButtonState.DISABLED:
			sprite_enabled.visible = false
			sprite_disabled.visible = true
			sprite_2d_hover.visible = false
			sprite_2d_pressed.visible = false
			sprite_2d_focused.visible = false

func set_highlight(active : bool):
	is_selected = active
	if is_selected and is_unlocked:
		sprite.scale = Vector2(init_scale.x + 0.05, init_scale.y + 0.05)
	else:
		sprite.scale = init_scale

func update_id(new_id: int):
	level_id = new_id
	label.text = str(level_id)
	collectables_visual.update_collected_count()


func _on_mouse_entered() -> void:
	is_selected = true
	if !is_unlocked:
		return
	current_state = ButtonState.HOVER
	set_sprite_state(current_state)
	set_highlight(true)

func _on_mouse_exited() -> void:
	if !is_unlocked:
		return
	current_state = ButtonState.IDLE
	set_sprite_state(current_state)
	set_highlight(false)
