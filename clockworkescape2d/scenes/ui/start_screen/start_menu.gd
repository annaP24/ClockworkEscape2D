extends Control
@onready var start_button: TextureButton = %StartButton
@onready var continue_button: TextureButton = %ContinueButton
@onready var settings_button: TextureButton = %SettingsButton
@onready var quit_button: TextureButton = %QuitButton

func _ready() -> void:
	EventBus.world_show_sm.connect(_on_show_received)

func _on_start_button_pressed() -> void:
	AudioManager.play_sfx("click")
	EventBus.sm_start_game.emit()

func _on_start_button_mouse_entered() -> void:
	on_mouse_entered(start_button)

func _on_start_button_mouse_exited() -> void:
	on_mouse_exited(start_button)

func _on_settings_button_pressed() -> void:
	AudioManager.play_sfx("click")
	EventBus.sm_settings.emit()

func _on_settings_button_mouse_entered() -> void:
	on_mouse_entered(settings_button)

func _on_settings_button_mouse_exited() -> void:
	on_mouse_exited(settings_button)

func _on_quit_button_pressed() -> void:
	AudioManager.play_sfx("click")
	EventBus.sm_quit_game.emit()

func _on_quit_button_mouse_entered() -> void:
	on_mouse_entered(quit_button)

func _on_quit_button_mouse_exited() -> void:
	on_mouse_exited(quit_button)

func _on_continue_button_pressed() -> void:
	AudioManager.play_sfx("click")
	EventBus.sm_start_game.emit()

func _on_continue_button_mouse_entered() -> void:
	on_mouse_entered(continue_button)

func _on_continue_button_mouse_exited() -> void:
	on_mouse_exited(continue_button)

func _on_show_received(is_show : bool):
	visible = is_show

func on_mouse_entered(button : TextureButton):
	button.pivot_offset = button.size / 2
	button.scale = Vector2(1.03, 1.03)
	var label = button.get_child(0)
	label.add_theme_color_override("font_color", Color("#3a240c"))

func on_mouse_exited(button : TextureButton):
	button.scale = Vector2(1.0, 1.0)
	var label = button.get_child(0)
	label.add_theme_color_override("font_color", Color("#2b1a07"))
