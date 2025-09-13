extends Node2D
class_name Level_64x64
signal quit_level
signal restart_level
signal load_next_level
@onready var collectable_scene = preload("res://scenes/collectables/collectable.tscn")
#@onready var player_scene = preload("res://scenes/character/character_32x32.tscn")
@onready var player_scene = preload("res://scenes/character/character_64x64.tscn")
@onready var spawn_marker: Marker2D = $SpawnMarker

var player
func _ready() -> void:
	FadeScreen.connect("fade_in_finished",_on_fade_in_finished)
	FadeScreen.fade_in()

func _on_fade_in_finished():
	spawn_collectable()
	spawn_player()	
	
func spawn_collectable():
	var collectable_node = get_node("Collectables")
	for collectable in collectable_node.get_children():
		var coll = collectable_scene.instantiate() as StaticBody2D
		collectable.add_child(coll)
	
func spawn_player():
	player = player_scene.instantiate() as PlayerFSM
	player.position = spawn_marker.position
	add_child(player)
	player.connect("player_died", _on_player_died)
	player.connect("player_finished", _on_player_finished)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("return"):
		quit_level.emit()

func _on_player_died():
	restart_level.emit()

func _on_player_finished():
	load_next_level.emit()
