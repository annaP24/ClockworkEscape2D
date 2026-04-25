extends Node

# Use a pool of players to handle multiple sounds at once
@export var sfx_pool_size: int = 16

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var pool_index: int = 0

# A dictionary to store preloaded sounds or use ResourcePaths
var sounds = {
	"ground_reached": preload("res://assets/sounds/825656__1love__1love_kick_ding.wav"),
	"click": preload("res://assets/sounds/click2.ogg"),
	"collected": preload("res://assets/sounds/788072__mediasaur__coin_collect.wav")
}

var music_tracks = {
	"main_theme": "res://assets/sounds/850443__cpfcfan10__tic-tock-goes-the-clock.wav"
}

func _ready() -> void:
	# Initialize Music Player
	music_player = AudioStreamPlayer.new()
	music_player.bus = &"Music"
	add_child(music_player)
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Initialize SFX Pool
	for i in sfx_pool_size:
		var p = AudioStreamPlayer.new()
		p.bus = &"SFX"
		add_child(p)
		sfx_players.append(p)

func _start_track(stream: AudioStream, fade_duration: float) -> void:
	music_player.stream = stream
	music_player.volume_db = -80.0 # Start silent
	music_player.play()

	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", 0.0, fade_duration)

func play_sfx(sfx_name: String, pitch_variance: float = 0.1) -> void:
	if not sounds.has(sfx_name):
		push_warning("SFX not found: ", sfx_name)
		return

	var player = sfx_players[pool_index]
	player.stream = sounds[sfx_name]

	# Add slight randomness to pitch to prevent "machine-gun" effect
	player.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)

	player.play()

	# Increment pool index
	pool_index = (pool_index + 1) % sfx_pool_size

func play_music(track_name: String, fade_duration: float = 1.0) -> void:
	if not music_tracks.has(track_name): return

	var stream  = load(music_tracks[track_name])
	# If music is already playing, fade out and switch
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(func(): _start_track(stream, fade_duration))
	else:
		_start_track(stream, fade_duration)


## --- Bus volume control (For Settings Menus) ---
func set_bus_volume(bus_name: String, linear_volume: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	# Convert 0.0-1.0 slider value to Decibels
	var db = linear_to_db(linear_volume)
	AudioServer.set_bus_volume_db(bus_index, db)

func play_sfx_for_object(sfx_name: String, position: Vector3):
	var p = AudioStreamPlayer2D.new()
	p.stream = sounds[sfx_name]
	p.bus = &"SFX"
	get_tree().root.add_child(p)
	p.play()
	# Clean up after finished
	p.finished.connect(p.queue_free)

func mute_all_sound(is_muted : bool):
	if is_muted:
		set_bus_volume("SFX",0.0)
		set_bus_volume("Music",0.0)
		set_bus_volume("Master",0.0)
	else:
		set_bus_volume("SFX",1.0)
		set_bus_volume("Music",1.0)
		set_bus_volume("Master",1.0)
