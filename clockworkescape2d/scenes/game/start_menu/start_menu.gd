extends Control
class_name StartMenu
@onready var start_button: TextureButton = %StartButton
@onready var settings_button: TextureButton = %SettingsButton
@onready var quit_button: TextureButton = %QuitButton

func _ready() -> void:
	if GameSaveManager.is_joypad_connected:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		start_button.grab_focus()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
