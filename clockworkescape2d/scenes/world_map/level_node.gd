extends Area2D
class_name LevelNode
signal level_selected(level_id)


@export var level_id: int
@export var is_unlocked: bool = false
@export var neighbour_up : LevelNode
@export var neighbour_down : LevelNode
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var collectables_visual: CollectableVisual = $CollectablesVisual
var parent : WorldMap
var is_selected : bool = false

func _ready():
	update_visual()
	collectables_visual.level_node = self

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and is_unlocked:
		trigger_button()

func trigger_button():
	level_selected.emit(level_id)

func update_visual():
	if is_unlocked:
		sprite_2d.modulate = Color.WHITE
		collectables_visual.update_visual(Color.WHITE)
		set_highlight(is_selected)
	else:
		sprite_2d.modulate = Color.GRAY
		collectables_visual.update_visual(Color.GRAY)
	collectables_visual.update_collected_count()
	label.text = str(level_id)


func set_highlight(active : bool):
	is_selected = active
	if is_selected:
		# Simple visual feedback (replace with an animation or shader)
		sprite_2d.modulate = Color(1.5, 1.5, 1.5) # Brighten
		sprite_2d.scale = Vector2(1.1, 1.1)
	else:
		sprite_2d.modulate = Color(1, 1, 1)
		sprite_2d.scale = Vector2(1, 1)

func _on_mouse_entered() -> void:
	is_selected = true
	set_highlight(true)
	parent._change_focus(self, false)

func _on_mouse_exited() -> void:
	set_highlight(false)
