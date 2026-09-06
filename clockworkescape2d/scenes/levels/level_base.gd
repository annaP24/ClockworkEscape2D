extends Node2D
class_name Level

@export var level_id : int
@onready var collectable_scene = preload("res://scenes/collectables/collectable.tscn")
@onready var player_scene = preload("res://scenes/character_custom_data_layer/character.tscn")
@onready var spawn_marker: Marker2D = $SpawnMarker

var engine_start := Time.get_ticks_msec()
var player : PlayerFsmCustomDataLayer

func _process(_delta):
	if Input.is_action_pressed("return"):
		#If root node's name is not "Game" then we are in debug mode and need restarting
		if get_tree().current_scene.name != "Game":
				get_tree().quit()

func _ready() -> void:
	FadeScreen.connect("fade_in_finished",_on_fade_in_finished)
	FadeScreen.fade_in()
	#var delta = Time.get_ticks_msec() - engine_start
	#print("Autoload-Init:", engine_start)
	#print("Zeit bis erstes _ready():", delta, "ms")
	print("Level ", str(level_id), " starting")
	EventBus.exit_animation_finished.connect(_on_exit_platform_level_finished)

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
		#Save current collected count to progress.cfg
		GameSaveManager.save_collectables_count_for_level(level_id, player.get_nr_of_collected_items())
		#Unlock the next level if this one wasn't already the highest reached
		var new_max_level = min(level_id + 1, GameSaveManager.MAX_NUM_OF_LEVELS)
		if new_max_level > GameSaveManager.max_level_reached:
			GameSaveManager.save_progress(new_max_level)
			GameSaveManager.max_level_reached = new_max_level
		EventBus.level_return_to_map.emit(level_id)
