extends Control

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
var current_sfx_vol : float = 0.5
var current_music_vol : float = 0.0
var current_brightness : float = 0.0

func _ready() -> void:
	EventBus.world_hide_settings_menu.connect(_on_hide_received)
	EventBus.button_pressed.connect(_on_button_pressed)
	_set_defaults()
	if GameManager.is_joypad_connected:
		music_slider.grab_focus()

func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume("Music", value)
	current_music_vol = value
	if value == 0.0:
		music_mute_button.set_pressed(true)
	else:
		music_mute_button.set_pressed(false)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume("SFX", value)
	current_sfx_vol = value
	if value == 0.0:
		sfx_mute_button.set_pressed(true)
	else:
		sfx_mute_button.set_pressed(false)

func _on_brightness_slider_value_changed(value: float) -> void:
	current_brightness = value
	EventBus.settings_brightness_changed.emit(value)

func _on_sfx_mute_button_toggled(toggled_on: bool) -> void:
	AudioManager.play_sfx("click")
	# If toggled_on we are muted
	# else go back to previous volume setting
	if toggled_on:
		AudioManager.set_bus_volume("SFX", 0.0)
		current_sfx_vol = 0.0
	else:
		AudioManager.set_bus_volume("SFX", sfx_slider.value)
		current_sfx_vol = sfx_slider.value


func _on_music_mute_button_toggled(toggled_on: bool) -> void:
	AudioManager.play_sfx("click")

	# If toggled_on we are muted
	# else go back to previous volume setting
	if toggled_on:
		AudioManager.set_bus_volume("Music", 0.0)
		current_music_vol = 0.0
	else:
		AudioManager.set_bus_volume("Music", music_slider.value)
		current_music_vol = music_slider.value

func _on_back_button_pressed() -> void:
	SettingManager.update_setting(SettingManager.SFX_VOLUME, current_sfx_vol)
	SettingManager.update_setting(SettingManager.MUSIC_VOLUME, current_music_vol)
	SettingManager.update_setting(SettingManager.BRIGHTNESS, current_brightness)
	SettingManager.update_setting(SettingManager.RESOLUTION, resolution_list.selected)
	EventBus.world_show_menu.emit(true)
	visible = false
	_update_settings()

func _on_default_button_pressed() -> void:
	_set_defaults()

func _set_defaults():
	sfx_slider.value = SettingManager.sfx_vol
	music_slider.value = SettingManager.music_vol
	brightness_slider.value = SettingManager.brightness
	resolution_list.selected = int(SettingManager.resolution)

func _on_menu_button_item_selected(index: int) -> void:
	var resolutions : PackedStringArray = resolution_list.get_item_text(index).split("x")
	DisplayServer.window_set_size(Vector2i(int(resolutions[0]), int(resolutions[1])))

func _update_settings()-> void:
	SettingManager.update_setting(SettingManager.SFX_VOLUME, sfx_slider.value)
	SettingManager.update_setting(SettingManager.MUSIC_VOLUME, music_slider.value)
	SettingManager.update_setting(SettingManager.BRIGHTNESS, brightness_slider.value)
	SettingManager.update_setting(SettingManager.RESOLUTION, resolution_list.selected)


# ---------------------- Signals ----------------------
func _on_button_pressed(button : TextureButton) -> void:
	if button == default_button:
		_on_default_button_pressed()
	elif button == back_button:
		_on_back_button_pressed()

func _on_hide_received(is_show : bool)-> void:
	visible = is_show