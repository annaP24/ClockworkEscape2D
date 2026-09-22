extends Node2D
class_name CutsceneManager

const MIDPOINT_COUNT: int = 20
const END_COUNT: int = 40

@onready var cut_scene: PackedScene = preload("uid://sn5oaox1clri")
const CAMERA_MOVE_DURATION: float = 5

var cutscene: MidPointCutScene = null
var is_playing: bool = false


var _gameplay_camera_position: Vector2


func _ready() -> void:

	if not EventBus.collectables_changed.is_connected(_on_collectables_changed):
		EventBus.collectables_changed.connect(_on_collectables_changed)


func _on_collectables_changed() -> void:
	if is_playing:
		return

	if GameSaveManager.collected_objects == MIDPOINT_COUNT:
		_startcutscene(true)
	elif GameSaveManager.collected_objects == END_COUNT:
		_startcutscene(false)


func _startcutscene(is_midpoint: bool) -> void:
	if is_playing:
		return

	var world: Node = get_tree().current_scene

	if world == null:
		push_error("CutsceneManager: Current scene is null.")
		return

	if not world.has_method("set_gameplay_frozen"):
		push_error("CutsceneManager: Current scene does not implement " + "set_gameplay_frozen().")
		return

	var camera: Camera2D = world.get_camera()

	if camera == null:
		push_error("CutsceneManager: Camera2D not found in World.")
		return

	is_playing = true

	# Remember exactly where gameplay camera was.
	_gameplay_camera_position = camera.global_position

	# Freeze the player and level.
	world.set_gameplay_frozen(true)

	# Create the temporary cinematic scene.
	cutscene = cut_scene.instantiate() as MidPointCutScene

	if cutscene == null:
		push_error("CutsceneManager: Could not instantiate MidPointCutScene.")

		# world.set_gameplay_frozen(false)
		is_playing = false
		return

	cutscene.set_is_end_scene(!is_midpoint)
	world.add_child(cutscene)
	cutscene.z_index = 10

	# Camera zoom < 1 means the world-space area shown is larger than the raw
	# pixel viewport size, so divide by zoom to get the real screen height.
	var viewport_size: Vector2 = get_viewport_rect().size / camera.zoom
	cutscene.global_position = _gameplay_camera_position - Vector2(0, viewport_size.y)

	# Move the active camera upward slowly until it reaches the cutscene view.
	await _move_camera_to(camera, cutscene.get_camera_target())
	cutscene.play()
	await cutscene.animation_finished
	await get_tree().process_frame
	await _move_camera_to(camera, _gameplay_camera_position)
	cutscene.queue_free()
	cutscene = null
	is_playing = false
	world.set_gameplay_frozen(false)

func _move_camera_to(camera: Camera2D, target_position: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(camera, "global_position", target_position, CAMERA_MOVE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
