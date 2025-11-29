extends TextureButton
class_name LevelButton_Circle

signal level_selected(level_id)

@onready var label: Label = $Label
@export var level_id : int = 0
@export var is_unlocked : bool = false
var scene_path : String

func _ready() -> void:
	label.text = str(level_id)

func set_text(content : String):
	label.text = content

func set_scene_path(level_path : String):
	scene_path = level_path

func _on_pressed() -> void:
	level_selected.emit(level_id)

func update_visual():
	if is_unlocked:
		disabled = false
	else:
		disabled = true
