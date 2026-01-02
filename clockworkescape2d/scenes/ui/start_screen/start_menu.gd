extends Control

signal start_game
signal quit_game
signal settings

func _on_start_button_pressed() -> void:
	start_game.emit()

func _on_settings_button_pressed() -> void:
	settings.emit()

func _on_quit_button_pressed() -> void:
	quit_game.emit()
