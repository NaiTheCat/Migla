extends AudioStreamPlayer

func _ready() -> void:
	var path: String = "res://audio/rain_loop.wav"
	if ResourceLoader.exists(path):
		var s: AudioStream = load(path)
		if s is AudioStreamWAV:
			s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream = s

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_9:
		if playing:
			stop()
		else:
			volume_db = -3
			play()
