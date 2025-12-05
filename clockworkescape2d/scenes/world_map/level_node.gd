extends Area2D
class_name LevelNode
@export var level_id: int
@export var is_unlocked: bool = false
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label

signal level_selected(level_id)

func _ready():
	update_visual()

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and is_unlocked:
		level_selected.emit(level_id)

func update_visual():
	if is_unlocked:
		sprite_2d.modulate = Color.WHITE
	else:
		sprite_2d.modulate = Color.GRAY
	label.text = str(level_id)
