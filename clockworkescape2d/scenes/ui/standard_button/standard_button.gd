extends TextureButton
class_name StandardButton

var is_toggled : bool = false
var normal_scale : Vector2 = Vector2(1.0, 1.0)

func _ready() -> void:
	normal_scale = scale
func _on_pressed() -> void:
	AudioManager.play_sfx("click")
	EventBus.button_pressed.emit(self)

func _on_toggled(toggled_on: bool) -> void:
	AudioManager.play_sfx("click")
	EventBus.button_toggled.emit(self, toggled_on)
	is_toggled = toggled_on

func _on_focus_entered() -> void:
	pivot_offset = size / 2
	scale = Vector2(normal_scale.x + 0.03, normal_scale.y + 0.03)
	var label = get_child(0)
	label.add_theme_color_override("font_color", Color("#3a240c"))


func _on_focus_exited() -> void:
	scale = normal_scale
	var label = get_child(0)
	label.add_theme_color_override("font_color", Color("#2b1a07"))


func _on_mouse_entered() -> void:
	_on_focus_entered()


func _on_mouse_exited() -> void:
	# if not is_toggled:
	_on_focus_exited()
