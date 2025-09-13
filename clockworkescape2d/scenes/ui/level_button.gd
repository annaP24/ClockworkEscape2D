extends TextureButton
class_name LevelButton
@onready var label: Label = $Label
@export var level : int = 0
var scene_path : String

func _ready() -> void:
	label.text = str(level)

func set_text(content : String):
	label.text = content
	
func set_scene_path(level_path : String):
	scene_path = level_path
