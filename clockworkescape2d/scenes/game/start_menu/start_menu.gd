extends Control
class_name StartMenu
@onready var start_button: TextureButton = %StartButton
@onready var settings_button: TextureButton = %SettingsButton
@onready var quit_button: TextureButton = %QuitButton

func _ready() -> void:
	if GameSaveManager.is_joypad_connected:
		start_button.grab_focus()
