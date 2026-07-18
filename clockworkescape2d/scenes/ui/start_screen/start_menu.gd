extends Control
@onready var start_button: TextureButton = %StartButton
@onready var settings_button: TextureButton = %SettingsButton
@onready var quit_button: TextureButton = %QuitButton

var is_joypad : bool = false

func _ready() -> void:
	EventBus.world_show_menu.connect(_on_show_received)
	EventBus.button_pressed.connect(_on_button_pressed)
	if GameManager.is_joypad_connected:
		start_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		AudioManager.play_sfx("click")

		var focused = get_viewport().gui_get_focus_owner()
		if focused == null:
			return
		if focused == start_button:
			EventBus.menu_show_game_slots.emit()
		elif focused == settings_button:
			EventBus.menu_show_settings.emit()
		elif focused == quit_button:
			EventBus.menu_quit_game.emit()
			
# ---------------------- Signals ----------------------
func _on_show_received(is_show : bool):
	visible = is_show
	if GameManager.is_joypad_connected:
		start_button.grab_focus()

func _on_button_pressed(button : TextureButton) -> void:
	if button == start_button:
		EventBus.menu_show_game_slots.emit()
	elif button == settings_button:
		EventBus.menu_show_settings.emit()
	elif button == quit_button:
		EventBus.menu_quit_game.emit()