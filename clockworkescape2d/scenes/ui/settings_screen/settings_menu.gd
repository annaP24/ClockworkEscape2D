extends Control

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider
@onready var brightness_slider: HSlider = %BrightnessSlider
@onready var music_mute_button: TextureButton = $ColorRect/VBoxContainer2/VBoxContainer/HBoxContainer/MusicMuteButton
@onready var sfx_mute_button: TextureButton = $ColorRect/VBoxContainer2/VBoxContainer/HBoxContainer2/SfxMuteButton
@onready var resolution_list: OptionButton = $ColorRect/VBoxContainer2/VBoxContainer/HBoxContainer5/MenuButton

var def_sfx_vol : float = 0.5
var def_music_vol : float = 0.5
var def_brightness : float = 0.0
var def_resolution : int = 2

func _ready() -> void:
	EventBus.world_hide_settings_menu.connect(_on_hide_received)
	_set_defaults()

func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume("Music", value)
	if value == 0.0:
		music_mute_button.set_pressed(true)
	else:
		music_mute_button.set_pressed(false)


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume("SFX", value)
	if value == 0.0:
		sfx_mute_button.set_pressed(true)
	else:
		sfx_mute_button.set_pressed(false)

func _on_brightness_slider_value_changed(value: float) -> void:
	EventBus.s_brightness_changed.emit(value)

func _on_sfx_mute_button_toggled(toggled_on: bool) -> void:
	AudioManager.play_sfx("click")
	# If toggled_on we are muted
	# else go back to previous volume setting
	if toggled_on:
		AudioManager.set_bus_volume("SFX", 0.0)
	else:
		AudioManager.set_bus_volume("SFX", sfx_slider.value)


func _on_music_mute_button_toggled(toggled_on: bool) -> void:
	AudioManager.play_sfx("click")

	# If toggled_on we are muted
	# else go back to previous volume setting
	if toggled_on:
		AudioManager.set_bus_volume("Music", 0.0)
	else:
		AudioManager.set_bus_volume("Music", 1.0)

func _on_hide_received(is_show : bool)-> void:
	visible = is_show

func _on_back_button_pressed() -> void:
	AudioManager.play_sfx("click")
	EventBus.world_show_sm.emit(true)
	visible = false


func _on_save_button_pressed() -> void:
	GameManager.save_settings()


func _on_default_button_pressed() -> void:
	_set_defaults()

func _set_defaults():
	sfx_slider.value = def_sfx_vol
	music_slider.value = def_music_vol
	brightness_slider.value = def_brightness
	resolution_list.selected = 0

func _on_menu_button_item_selected(index: int) -> void:
	var resolutions : PackedStringArray = resolution_list.get_item_text(index).split("x")
	DisplayServer.window_set_size(Vector2i(int(resolutions[0]), int(resolutions[1])))
