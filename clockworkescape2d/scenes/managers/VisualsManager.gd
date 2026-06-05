extends Node


func on_mouse_entered(button : TextureButton):
	button.pivot_offset = button.size / 2
	button.scale = Vector2(1.03, 1.03)
	var label = button.get_child(0)
	label.add_theme_color_override("font_color", Color("#3a240c"))

func on_mouse_exited(button : TextureButton):
	button.scale = Vector2(1.0, 1.0)
	var label = button.get_child(0)
	label.add_theme_color_override("font_color", Color("#2b1a07"))
