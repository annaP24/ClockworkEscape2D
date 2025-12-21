extends Area2D
class_name LevelNode
signal level_selected(level_id)


@export var level_id: int
@export var is_unlocked: bool = false
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var collectables_visual: CollectableVisual = $CollectablesVisual

func _ready():
	update_visual()
	collectables_visual.level_node = self

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and is_unlocked:
		level_selected.emit(level_id)

func update_visual():
	if is_unlocked:
		sprite_2d.modulate = Color.WHITE
		collectables_visual.update_visual(Color.WHITE)
	else:
		sprite_2d.modulate = Color.GRAY
		collectables_visual.update_visual(Color.GRAY)
	collectables_visual.update_collected_count()
	label.text = str(level_id)
