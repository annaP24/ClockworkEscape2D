extends Control
class_name SettingsMenu
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider
@onready var brightness_slider: HSlider = %BrightnessSlider
@onready var music_mute_button: TextureButton =%MusicMuteButton
@onready var sfx_mute_button: TextureButton = %SfxMuteButton
@onready var resolution_list: OptionButton = %MenuButton
@onready var default_button: TextureButton = %DefaultButton
@onready var back_button: TextureButton = %BackButton

var def_sfx_vol : float = 0.5
var def_music_vol : float = 0.0
var def_brightness : float = 0.0
var def_resolution : int = 2
var current_resolution : int = 2
var current_brightness : float = 0.0

func _ready() -> void:
	_load_settings()
	if GameSaveManager.is_joypad_connected:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		music_slider.grab_focus()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume("Music", value)
	if value == 0.0:
		music_mute_button.set_pressed_no_signal(true)
	else:
		music_mute_button.set_pressed_no_signal(false)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume("SFX", value)
	if value == 0.0:
		sfx_mute_button.set_pressed_no_signal(true)
	else:
		sfx_mute_button.set_pressed_no_signal(false)

func _on_brightness_slider_value_changed(value: float) -> void:
	current_brightness = value
	EventBus.settings_brightness_changed.emit(value)

func _on_sfx_mute_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		sfx_slider.value = 0.0
	else:
		sfx_slider.value = SettingManager.sfx_vol
	AudioManager.set_bus_volume.call_deferred("SFX", sfx_slider.value)

func _on_music_mute_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.set_bus_volume("Music", 0.0)
		music_slider.value = 0.0
	else:
		AudioManager.set_bus_volume("Music", music_slider.value)
		music_slider.value = SettingManager.music_vol

func set_defaults():
	sfx_slider.value = SettingManager.default_sfx_vol
	music_slider.value = SettingManager.default_music_vol
	brightness_slider.value = SettingManager.default_brightness
	resolution_list.selected = int(SettingManager.default_resolution)

func _load_settings():
	sfx_slider.value = SettingManager.sfx_vol
	music_slider.value = SettingManager.music_vol
	brightness_slider.value = SettingManager.brightness
	resolution_list.selected = int(SettingManager.resolution)

func _on_menu_button_item_selected(index: int) -> void:
	var resolutions : PackedStringArray = resolution_list.get_item_text(index).split("x")
	DisplayServer.window_set_size(Vector2i(int(resolutions[0]), int(resolutions[1])))

func update_settings()-> void:
	SettingManager.update_setting(SettingManager.SFX_VOLUME, sfx_slider.value)
	SettingManager.update_setting(SettingManager.MUSIC_VOLUME, music_slider.value)
	SettingManager.update_setting(SettingManager.BRIGHTNESS, brightness_slider.value)
	SettingManager.update_setting(SettingManager.RESOLUTION, resolution_list.selected)
