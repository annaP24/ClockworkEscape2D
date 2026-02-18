extends Control

signal start_game
signal quit_game
signal settings
@onready var start_button: TextureButton = $ColorRect/VBoxContainer/StartButton
@onready var continue_button: TextureButton = $ColorRect/VBoxContainer/ContinueButton
@onready var settings_button: TextureButton = $ColorRect/VBoxContainer/SettingsButton
@onready var quit_button: TextureButton = $ColorRect/VBoxContainer/QuitButton

func _on_start_button_pressed() -> void:
	start_game.emit()

func _on_start_button_mouse_entered() -> void:
	on_mouse_entered(start_button)

func _on_start_button_mouse_exited() -> void:
	on_mouse_exited(start_button)


func _on_settings_button_pressed() -> void:
	settings.emit()

func _on_settings_button_mouse_entered() -> void:
	on_mouse_entered(settings_button)

func _on_settings_button_mouse_exited() -> void:
	on_mouse_exited(settings_button)


func _on_quit_button_pressed() -> void:
	quit_game.emit()

func _on_quit_button_mouse_entered() -> void:
	on_mouse_entered(quit_button)

func _on_quit_button_mouse_exited() -> void:
	on_mouse_exited(quit_button)

func _on_continue_button_pressed() -> void:
	start_game.emit()

func _on_continue_button_mouse_entered() -> void:
	on_mouse_entered(continue_button)

func _on_continue_button_mouse_exited() -> void:
	on_mouse_exited(continue_button)


func on_mouse_entered(button : TextureButton):
	button.scale = Vector2(1.03, 1.03)
	var label = button.get_child(0)
	label.add_theme_color_override("font_color", Color("#3a240c"))

func on_mouse_exited(button : TextureButton):
	button.scale = Vector2(1.0, 1.0)
	var label = button.get_child(0)
	label.add_theme_color_override("font_color", Color("#2b1a07"))
