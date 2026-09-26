extends Node2D
class_name MidPointCutScene

signal animation_finished
@export var timeout : float = 5.0
const GearInClockScript = preload("res://scenes/game/end_scene/gear_in_clock.gd")
@onready var animation_player_first: AnimationPlayer = %AnimationPlayer_first_part
@onready var first_gears: Node2D = $Collectables/First
@onready var second_gears: Node2D = $Collectables/Second
@onready var camera_target: Camera2D = $Camera2D
@onready var timeout_timer: Timer = $TimeoutTimer
@onready var animation_player_second: AnimationPlayer = %AnimationPlayer_second_part
var gear_scene : PackedScene = preload("res://scenes/collectables/end_scene_collectable.tscn")
var marker_counter : int = 0
var isRotateRight: bool = true
var isEndScene : bool = false

func _ready() -> void:
	animation_player_first.animation_finished.connect(_on_animation_finished)
	timeout_timer.timeout.connect(_on_timeout)
	if isEndScene:
		_fill_left_side()
		animation_player_second.play("rotate_bg_1")
		
func set_is_end_scene(value: bool) -> void:
	isEndScene = value

func get_camera_target() -> Vector2:
	return camera_target.global_position

func play() -> void:
	animation_player_first.play("place_collectables")

func _fill_left_side()-> void:
	for i in range(first_gears.get_child_count()):
		var gear_target : Node2D = first_gears.get_child(i)
		var gear : Node2D = gear_scene.instantiate() as EndSceneCollectable
		add_child(gear)
		gear.scale = Vector2(2.0, 2.0)
		gear.modulate = Color("#ffffff")
		if isRotateRight:
			gear.set_rotation_direction(EndSceneCollectable.Direction.RIGHT)
		else:
			gear.set_rotation_direction(EndSceneCollectable.Direction.LEFT)

		isRotateRight = !isRotateRight
		gear.global_position = gear_target.global_position
		gear.global_rotation = gear_target.global_rotation
		gear_target.queue_free()
	

func _fly_in_the_gear():
	var gear : Node2D = gear_scene.instantiate() as EndSceneCollectable
	add_child(gear)
	gear.scale = Vector2(2.0, 2.0)
	# Divide by zoom to convert pixel viewport size into world-space size.
	var viewport_size : Vector2 = get_viewport_rect().size / camera_target.zoom
	gear.global_position = global_position + Vector2(randf_range(0.0, viewport_size.x), viewport_size.y)

	if isRotateRight:
		gear.set_rotation_direction(EndSceneCollectable.Direction.RIGHT)
	else:
		gear.set_rotation_direction(EndSceneCollectable.Direction.LEFT)

	isRotateRight = !isRotateRight
	var target : Node2D
	if marker_counter < first_gears.get_child_count() and !isEndScene:	
		target = first_gears.get_child(marker_counter)
	elif marker_counter < second_gears.get_child_count():
		target = second_gears.get_child(marker_counter)
	else:
		return
	var target_position : Vector2 = target.global_position
	gear.global_rotation = target.global_rotation
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(gear, "global_position", target_position, 1.0)
	marker_counter += 1
	await tween.finished
	target.modulate = Color(1, 1, 1, 0)

func _start_clock_gears_rotating() -> void:
	var clock_hands: Node2D = %ClockHands
	var is_clockwise: bool = true
	var direction: GearInClockScript.RotationDirection
	for gear: Node2D in clock_hands.get_children():
		if is_clockwise:
			direction = GearInClockScript.RotationDirection.CLOCKWISE
		else:
			direction = GearInClockScript.RotationDirection.COUNTERCLOCKWISE
		gear.start_rotation(direction)
		is_clockwise = !is_clockwise
# ---------------------- Signals ----------------------------------
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "place_collectables":
		if isEndScene:
			_start_clock_gears_rotating()
			animation_player_first.play("rotate_bg_2")
		else:
			animation_player_first.play("rotate_bg_1")
	timeout_timer.start(timeout)


func _on_timeout() -> void:
	animation_finished.emit()
