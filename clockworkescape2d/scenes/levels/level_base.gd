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
		#If root node's name is not "World" then we are in debug mode and need restarting
		if get_tree().current_scene.name != "World":
				get_tree().quit()

func _ready() -> void:
	FadeScreen.connect("fade_in_finished",_on_fade_in_finished)
	FadeScreen.fade_in()
	#var delta = Time.get_ticks_msec() - engine_start
	#print("Autoload-Init:", engine_start)
	#print("Zeit bis erstes _ready():", delta, "ms")
	print("Level ", str(level_id), " starting")
	EventBus.exit_level_finished.connect(_on_exit_platform_level_finished)

func _on_fade_in_finished():
	_spawn_player( )

func _spawn_player():
	player = player_scene.instantiate() as PlayerFsmCustomDataLayer
	player.position = spawn_marker.position
	add_child(player)
	player.connect("player_died", _on_player_died)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		EventBus.lb_quit_level.emit()
		# Prevents the action propagating to _unhandled_input of world_new and doe not show mainmenu for a moment
		get_viewport().set_input_as_handled()

func _on_player_died():
	GameManager.update_number_of_deaths()
	EventBus.lb_restart_level.emit()

func _on_exit_platform_level_finished() -> void:
	#If root node's name is not "World" then we are in debug mode and need restarting
	if get_tree().current_scene.name != "World":
		get_tree().call_deferred("reload_current_scene")
	else:
		#Save current collected count to progress.cfg
		GameManager.save_collectables_count_for_level(level_id, player.get_nr_of_collected_items())
		EventBus.lb_return_to_map.emit(level_id)
