extends Node

var _sfx_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer
var _rain_sfx_player: AudioStreamPlayer

const SOUNDS: Dictionary = {
	"collect": "res://audio/collect.wav",
	"eat": "res://audio/eat.wav",
	"jump": "res://audio/jump.wav",
}

const SOUND_VOLUMES: Dictionary = {
	"collect": 10.0,
	"eat": 10.0,
	"jump": 10.0,
}

const MUSIC: Dictionary = {
	"menu": "res://audio/music/menu_theme.wav",
	"gameplay": "res://audio/music/gameplay_theme.wav",
}

func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	add_child(_sfx_player)
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	_rain_sfx_player = AudioStreamPlayer.new()
	add_child(_rain_sfx_player)

func play_sfx(sound_name: String) -> void:
	if not SOUNDS.has(sound_name):
		return
	var path: String = SOUNDS[sound_name]
	if not ResourceLoader.exists(path):
		return
	_sfx_player.stream = load(path)
	_sfx_player.volume_db = SOUND_VOLUMES.get(sound_name, -5.0)
	_sfx_player.play()

func play_sfx_test(path: String) -> void:
	if not ResourceLoader.exists(path):
		print("Test file missing: ", path)
		return
	_sfx_player.stream = load(path)
	_sfx_player.volume_db = 15
	_sfx_player.play()
	print("Test playing: ", _sfx_player.playing)

func play_music(track_name: String) -> void:
	if not MUSIC.has(track_name):
		return
	var path: String = MUSIC[track_name]
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_music_player.stream = stream
	_music_player.volume_db = -8
	_music_player.play()

func start_rain_sound() -> void:
	var path: String = "res://audio/rain_loop.wav"
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_rain_sfx_player.stream = stream
	_rain_sfx_player.volume_db = -3
	_rain_sfx_player.play()

func stop_rain_sound() -> void:
	_rain_sfx_player.stop()
