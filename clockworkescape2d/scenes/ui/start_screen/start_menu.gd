extends Control
@onready var start_button: TextureButton = %StartButton
@onready var settings_button: TextureButton = %SettingsButton
@onready var quit_button: TextureButton = %QuitButton

var is_joypad : bool = false

func _ready() -> void:
	EventBus.world_show_sm.connect(_on_show_received)
	if GameManager.is_joypad_connected:
		start_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		AudioManager.play_sfx("click")

		var focused = get_viewport().gui_get_focus_owner()
		if focused == null:
			return
		if focused.name == "StartButton":
			EventBus.sm_show_game_slots.emit()
		elif focused.name == "SettingsButton":
			EventBus.sm_settings.emit()
		elif focused.name == "QuitButton":
			EventBus.sm_quit_game.emit()


func _on_start_button_pressed() -> void:
	AudioManager.play_sfx("click")
	EventBus.sm_show_game_slots.emit()

func _on_start_button_mouse_entered() -> void:
	VisualsManager.on_mouse_entered(start_button)

func _on_start_button_mouse_exited() -> void:
	VisualsManager.on_mouse_exited(start_button)

func _on_settings_button_pressed() -> void:
	AudioManager.play_sfx("click")
	EventBus.sm_settings.emit()

func _on_settings_button_mouse_entered() -> void:
	VisualsManager.on_mouse_entered(settings_button)

func _on_settings_button_mouse_exited() -> void:
	VisualsManager.on_mouse_exited(settings_button)

func _on_quit_button_pressed() -> void:
	AudioManager.play_sfx("click")
	EventBus.sm_quit_game.emit()

func _on_quit_button_mouse_entered() -> void:
	VisualsManager.on_mouse_entered(quit_button)

func _on_quit_button_mouse_exited() -> void:
	VisualsManager.on_mouse_exited(quit_button)

func _on_show_received(is_show : bool):
	visible = is_show
	if GameManager.is_joypad_connected:
		start_button.grab_focus()

func _on_start_button_focus_entered() -> void:
	VisualsManager.on_mouse_entered(start_button)

func _on_start_button_focus_exited() -> void:
	VisualsManager.on_mouse_exited(start_button)

func _on_settings_button_focus_entered() -> void:
	VisualsManager.on_mouse_entered(settings_button)

func _on_settings_button_focus_exited() -> void:
	VisualsManager.on_mouse_exited(settings_button)

func _on_quit_button_focus_entered() -> void:
	VisualsManager.on_mouse_entered(quit_button)

func _on_quit_button_focus_exited() -> void:
	VisualsManager.on_mouse_exited(quit_button)
