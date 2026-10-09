extends Node2D
class_name CutsceneManager

const MIDPOINT_COUNT: int = 20
const END_COUNT: int = 40

@onready var cut_scene: PackedScene = preload("uid://sn5oaox1clri")
const CAMERA_MOVE_DURATION: float = 5

var spawned_end_scene: MidPointCutScene = null
var is_playing: bool = false
var end_scene_camera_transition_started: bool = false
var is_mid_scene_finished: bool = false

var gameplay_camera_position: Vector2


func _process(_delta: float) -> void:
	if not is_instance_valid(spawned_end_scene) or end_scene_camera_transition_started:
		return

	var world: Node = get_tree().current_scene
	if world == null or not world.has_method("get_camera"):
		return

	var camera: Camera2D = world.get_camera()
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if camera == null or player == null or player.global_position.y > camera.global_position.y:
		return

	end_scene_camera_transition_started = true
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(camera, "global_position", spawned_end_scene.global_position, CAMERA_MOVE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _ready() -> void:

	if not EventBus.key_collected.is_connected(_on_key_collected):
		EventBus.key_collected.connect(_on_key_collected)


func _on_key_collected() -> void:
	if is_instance_valid(spawned_end_scene):
		return

	var world: Node = get_tree().current_scene
	if world == null:
		push_error("CutSceneManager: Current scene is null.")
		return

	var camera: Camera2D = _get_gameplay_camera(world)
	if camera == null:
		return

	spawned_end_scene = _create_cutscene(true, camera, camera.global_position)
	if spawned_end_scene == null:
		return
	world.add_child(spawned_end_scene)

	end_scene_camera_transition_started = false
	spawned_end_scene.start_end_scene_immediately()


## Plays a cutscene whose collectable threshold was reached on a completed run, once per save slot.
func play_pending_cutscene() -> void:
	var total := GameSaveManager.get_total_collected()
	if total >= MIDPOINT_COUNT and not GameSaveManager.is_scene_seen(GameSaveManager.MID_SCENE_SEEN_TAG):
		GameSaveManager.mark_scene_seen(GameSaveManager.MID_SCENE_SEEN_TAG)
		await start_cutscene(true)
	elif total >= END_COUNT and not GameSaveManager.is_scene_seen(GameSaveManager.END_SCENE_SEEN_TAG):
		GameSaveManager.mark_scene_seen(GameSaveManager.END_SCENE_SEEN_TAG)
		await start_cutscene(false)


func start_cutscene(is_midpoint: bool) -> void:
	if is_playing:
		return

	var world: Node = get_tree().current_scene

	if world == null:
		push_error("CutsceneManager: Current scene is null.")
		return

	if not world.has_method("set_gameplay_frozen"):
		push_error("CutsceneManager: Current scene does not implement " + "set_gameplay_frozen().")
		return

	var camera: Camera2D = _get_gameplay_camera(world)
	if camera == null:
		return

	# Remember exactly where gameplay camera was.
	gameplay_camera_position = camera.global_position
	var active_cutscene: MidPointCutScene = _create_cutscene(!is_midpoint, camera, gameplay_camera_position)
	if active_cutscene == null:
		return

	# Freeze the player and level.
	is_playing = true
	world.set_gameplay_frozen(true)

	world.add_child(active_cutscene)

	# Move the active camera upward slowly until it reaches the cutscene view.
	await _move_camera_to(camera, active_cutscene.get_camera_target())
	active_cutscene.play()
	await active_cutscene.animation_finished
	await get_tree().process_frame
	await _move_camera_to(camera, gameplay_camera_position)
	active_cutscene.queue_free()
	is_playing = false
	world.set_gameplay_frozen(false)
	if is_midpoint:
		is_mid_scene_finished = true
		
func _move_camera_to(camera: Camera2D, target_position: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(camera, "global_position", target_position, CAMERA_MOVE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func _get_gameplay_camera(world: Node) -> Camera2D:
	if not world.has_method("get_camera"):
		push_error("CutSceneManager: Current scene does not provide a gameplay camera.")
		return null

	var camera: Camera2D = world.get_camera()
	if camera == null:
		push_error("CutSceneManager: Camera2D not found in World.")
	return camera


func _create_cutscene(is_end_scene: bool, camera: Camera2D, camera_position: Vector2) -> MidPointCutScene:
	var instance: MidPointCutScene = cut_scene.instantiate() as MidPointCutScene
	if instance == null:
		push_error("CutsceneManager: Could not instantiate MidPointCutScene.")
		return null

	instance.set_is_end_scene(is_end_scene)
	instance.set_camera_zoom(camera.zoom)
	instance.z_index = -1
	var viewport_size: Vector2 = get_viewport_rect().size / camera.zoom
	instance.global_position = camera_position - Vector2(0, viewport_size.y)
	return instance