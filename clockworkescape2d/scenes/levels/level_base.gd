extends Node2D
class_name Level
signal quit_level
signal restart_level
signal load_next_level(level_id)
@export var level_id : int
@onready var collectable_scene = preload("res://scenes/collectables/collectable.tscn")
#@onready var player_scene = preload("res://scenes/character_new/character.tscn")
@onready var player_scene = preload("res://scenes/character_alternative/character.tscn")
@onready var spawn_marker: Marker2D = $SpawnMarker
var engine_start := Time.get_ticks_msec()
var player : PlayerFsmAlternative

func _ready() -> void:
	FadeScreen.connect("fade_in_finished",_on_fade_in_finished)
	FadeScreen.fade_in()
	var delta = Time.get_ticks_msec() - engine_start
	print("Autoload-Init:", engine_start)
	print("Zeit bis erstes _ready():", delta, "ms")

func _on_fade_in_finished():
	_spawn_player( )

func _spawn_player():
	player = player_scene.instantiate() as PlayerFsmAlternative
	player.position = spawn_marker.position
	add_child(player)
	player.connect("player_died", _on_player_died)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("return"):
		quit_level.emit()

func _on_player_died():
	restart_level.emit()

func _on_exit_level_finished() -> void:
	#If root node's name is not "World" then we are in debug mode and need restarting
	if get_tree().current_scene.name != "World":
		get_tree().call_deferred("reload_current_scene")
	else:
		#Save current collected count to progress.cfg
		GameManager.save_collectables_count_for_level(level_id, player.get_nr_of_collected_items())
		load_next_level.emit(level_id)
