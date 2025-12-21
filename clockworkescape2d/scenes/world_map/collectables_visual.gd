extends Node2D
class_name CollectableVisual
@onready var coll_1: Sprite2D = $Sprites/Coll_1
@onready var coll_2: Sprite2D = $Sprites/Coll_2
@onready var coll_3: Sprite2D = $Sprites/Coll_3

@onready var level_node : LevelNode = get_parent()

var sprite_img_full = preload("res://scenes/world_map/assets/collectable.png")
var sprite_img_empty = preload("res://scenes/world_map/assets/collectable_disabled.png")
var collected_count : int = 0
var level_id : int = 0
var is_unlocked : bool = false

func _ready() -> void:
	if level_node != null:
		level_id = level_node.level_id
		is_unlocked = level_node.is_unlocked
	update_collected_count()

func update_collected_count():
	collected_count = GameManager.get_collected_count_for_level(level_id)
	set_images()

func set_images():
	match collected_count:
		1:
			coll_1.texture = sprite_img_full
			coll_2.texture = sprite_img_empty
			coll_3.texture = sprite_img_empty
		2:
			coll_1.texture = sprite_img_full
			coll_2.texture = sprite_img_full
			coll_3.texture = sprite_img_empty

		3:
			coll_1.texture = sprite_img_full
			coll_2.texture = sprite_img_full
			coll_3.texture = sprite_img_full
		0:
			coll_1.texture = sprite_img_empty
			coll_2.texture = sprite_img_empty
			coll_3.texture = sprite_img_empty

func update_visual(col : Color):
	coll_1.modulate = col
	coll_2.modulate = col
	coll_3.modulate = col

func get_level_id() -> int:
	return level_node.level_id

func get_is_unlocked() -> int:
	return level_node.is_unlocked
