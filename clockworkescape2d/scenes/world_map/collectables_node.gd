extends Node2D

@export var level_node : LevelNode 
var sprite1_img_full
var sprite2_img_full 
var sprite3_img_full
var sprite1_img_empty
var sprite2_img_empty 
var sprite3_img_empty
var level_id : int = 0
var is_unlocked : bool = false

func _ready() -> void:
	if level_node != null:
		level_id = level_node.level_id
		is_unlocked = level_node.is_unlocked

func update_visual():
	if get_is_unlocked():
		pass
	
func get_level_id() -> int:
	return 	level_node.level_id

func get_is_unlocked() -> int:
	return 	level_node.is_unlocked

func get_max_collectables():
	pass
