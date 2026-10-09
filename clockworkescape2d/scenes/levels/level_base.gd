extends Node2D
class_name Level

@export var level_id : int
@onready var collectable_scene = preload("res://scenes/collectables/collectable.tscn")
@onready var player_scene = preload("res://scenes/character_custom_data_layer/character.tscn")
@onready var spawn_marker: Marker2D = $SpawnMarker
@onready var background: Background = %Background
@onready var camera_2d: Camera2D
var engine_start := Time.get_ticks_msec()
var player : PlayerFsmCustomDataLayer
## Collectables picked up in this run; saved only when the exit is reached.
var run_mask : int = 0

func _process(_delta):
	if Input.is_action_pressed("return"):
		#If root node's name is not "Game" then we are in debug mode and need restarting
		if get_tree().current_scene.name != "Game":
				get_tree().quit()
	if CutSceneManager.is_mid_scene_finished and !background.is_background_running() == false:
		background.rotate_gears()

func _ready() -> void:
	FadeScreen.connect("fade_in_finished",_on_fade_in_finished)
	FadeScreen.fade_in()
	#var delta = Time.get_ticks_msec() - engine_start
	#print("Autoload-Init:", engine_start)
	#print("Zeit bis erstes _ready():", delta, "ms")
	print("Level ", str(level_id), " starting")
	EventBus.exit_animation_finished.connect(_on_exit_platform_level_finished)
	camera_2d = %Camera2D
	CutSceneManager.is_mid_scene_finished = GameSaveManager.is_scene_seen(GameSaveManager.MID_SCENE_SEEN_TAG)
	_setup_collectables()

func _setup_collectables() -> void:
	var saved_mask := GameSaveManager.get_collected_mask(level_id)
	var index := 0
	for node in get_tree().get_nodes_in_group("collectable"):
		if not is_ancestor_of(node):
			continue
		node.index = index
		if saved_mask & (1 << index):
			# Notify listeners (e.g. tutorials) as if it was picked up, then remove it.
			node.collected.emit()
			node.queue_free()
		else:
			node.collected.connect(_on_collectable_collected.bind(index))
		index += 1

func _on_collectable_collected(index : int) -> void:
	run_mask |= 1 << index

func _on_fade_in_finished():
	_spawn_player( )

func _spawn_player():
	player = player_scene.instantiate() as PlayerFsmCustomDataLayer
	player.position = spawn_marker.position
	add_child(player)
	player.player_died.connect(_on_player_died)
	if has_node("TutorialController"):
		var tutorial_controller = get_node("TutorialController") as Node
		tutorial_controller.player = player
	await CutSceneManager.play_pending_cutscene()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		EventBus.level_quit_requested.emit()
		# Prevents the action propagating to _unhandled_input of world_new and doe not show mainmenu for a moment
		get_viewport().set_input_as_handled()

func _on_player_died():
	GameSaveManager.update_number_of_deaths()
	EventBus.level_restart_requested.emit()

func _on_exit_platform_level_finished() -> void:
	#If root node's name is not "World" then we are in debug mode and need restarting
	if get_tree().current_scene.name != "Game":
		get_tree().call_deferred("reload_current_scene")
	else:
		GameSaveManager.commit_level_collectables(level_id, run_mask)
		#Unlock the next level if this one wasn't already the highest reached
		var new_max_level = min(level_id + 1, GameSaveManager.MAX_NUM_OF_LEVELS)
		if new_max_level > GameSaveManager.max_level_reached:
			GameSaveManager.save_progress(new_max_level)
			GameSaveManager.max_level_reached = new_max_level
		EventBus.level_return_to_map.emit(level_id)

func get_camera() -> Camera2D:
	return camera_2d

func set_gameplay_frozen(frozen: bool, is_check_player: bool = true) -> void:
	if frozen:
		if is_check_player:
			while not player.is_on_floor():
				await get_tree().physics_frame
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		process_mode = Node.PROCESS_MODE_INHERIT
