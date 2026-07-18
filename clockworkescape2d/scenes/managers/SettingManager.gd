extends Node

# Settings tags/keys for ConfigFile
const SFX_VOLUME = "sfx_volume"
const MUSIC_VOLUME = "music_volume"
const BRIGHTNESS = "brightness"
const RESOLUTION = "resolution"
const SETTINGS_PATH = "res://settings.cfg"

# Default settings values
var sfx_vol: float = 0.5
var music_vol: float = 0.5
var brightness: float = 1.0
var resolution: float = 0.0
var is_muted: bool = false


## Load a specific setting from the progress file
func load_setting(setting_name: String) -> float:
	var cf = ConfigFile.new()
	if cf.load(SETTINGS_PATH) == OK:
		return cf.get_value("settings", setting_name, 1.0)
	return 1.0

## Update a setting in the progress file
func update_setting(setting_name: String, value: float) -> void:
	var cf = ConfigFile.new()

	# Load existing config if it exists
	if FileAccess.file_exists(SETTINGS_PATH):
		cf.load(SETTINGS_PATH)

	# Update the setting
	cf.set_value("settings", setting_name, value)

	# Save to disk
	cf.save(SETTINGS_PATH)


## Save brightness setting specifically
func save_brightness_setting(value: float) -> void:
	update_setting(BRIGHTNESS, value)
	brightness = value


## Initialize default settings in a config file
func create_default_settings(cf: ConfigFile) -> void:
	cf.set_value("settings", SFX_VOLUME, sfx_vol)
	cf.set_value("settings", MUSIC_VOLUME, music_vol)
	cf.set_value("settings", BRIGHTNESS, brightness)
	cf.set_value("settings", RESOLUTION, resolution)


## Load all settings from progress file into member variables
func load_all_settings() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		sfx_vol = load_setting(SFX_VOLUME)
		music_vol = load_setting(MUSIC_VOLUME)
		brightness = load_setting(BRIGHTNESS)
		resolution = load_setting(RESOLUTION)


## Update SFX volume
func set_sfx_volume(value: float) -> void:
	sfx_vol = value
	update_setting(SFX_VOLUME, value)


## Update music volume
func set_music_volume(value: float) -> void:
	music_vol = value
	update_setting(MUSIC_VOLUME, value)


## Update resolution
func set_resolution(value: float) -> void:
	resolution = value
	update_setting(RESOLUTION, value)


## Toggle mute state
func toggle_mute() -> bool:
	is_muted = !is_muted
	return is_muted
