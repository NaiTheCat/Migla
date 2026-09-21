extends Node2D
class_name World

var _db: Database

var _rain: CPUParticles2D
var _rain_overlay: Sprite2D
var _rain_timer: Timer
var _rain_back: CPUParticles2D
@onready var _rain_player: AudioStreamPlayer = $RainPlayer


const CHUNKS_AHEAD: int = 8
const CHUNKS_BEHIND: int = 4

@export var _player: Node2D

var _chunk_scene: PackedScene = preload('res://chunk.tscn')
var _active_chunks: Array = []
var _last_player_chunk: int = -999


func _ready() -> void:
	_db = Database.new()
	add_child(_db)
	_setup_rain_timer()


func _process(_delta: float) -> void:
	var current_chunk: int = _get_player_chunk_index()
	if current_chunk != _last_player_chunk:
		_last_player_chunk = current_chunk
		_update_chunks()
	_save_distance()

	if is_instance_valid(_rain):
		_rain.position = Vector2(_player.position.x, -200)

	if is_instance_valid(_rain_back):
		_rain_back.position = Vector2(_player.position.x, -200)


func _get_player_chunk_index() -> int:
	'which chunk is the player currently standing on'
	if _player == null:
		return 0
	return int(_player.position.x / Chunk.CHUNK_WIDTH)

func _update_chunks() -> void:
	var player_chunk: int = _get_player_chunk_index()
	var min_chunk: int = player_chunk - CHUNKS_BEHIND
	var max_chunk: int = player_chunk + CHUNKS_AHEAD
	print('Updating chunks. Player chunk: ', player_chunk, " Range: ", min_chunk, " to ", max_chunk)

	for i in range(min_chunk, max_chunk + 1):
		if not _chunk_exists(i):
			_spawn_chunk(i)

	var to_remove: Array = []
	for chunk in _active_chunks:
		if chunk._chunk_index < min_chunk or chunk._chunk_index > max_chunk:
			to_remove.append(chunk)

	for chunk in to_remove:
		_active_chunks.erase(chunk)
		chunk.queue_free()


func _chunk_exists(index: int) -> bool:
	for chunk in _active_chunks:
		if chunk._chunk_index == index:
			return true
	return false


func _spawn_chunk(index: int) -> void:
	'create a new chunk and add it to world'
	var new_chunk: Chunk = _chunk_scene.instantiate()
	add_child(new_chunk)
	new_chunk.setup(index)
	_active_chunks.append(new_chunk)


func _save_distance() -> void:
	"tracks furthest distance travelled and saves it"
	if GameState.current_game_id == -1:
		return
	var distance: int = int(_player.position.x)
	if distance > 0:
		_db.save_progress(GameState.current_game_id, distance)


func _setup_rain_timer() -> void:
	"cycles rain on/off every so often"
	_rain_timer = Timer.new()
	_rain_timer.wait_time = 90.0
	_rain_timer.autostart = true
	_rain_timer.timeout.connect(_toggle_rain)
	add_child(_rain_timer)


func _toggle_rain() -> void:
	"turns rain on if off, off if on"
	if _rain == null:
		_start_rain()
	else:
		_stop_rain()


func _start_rain() -> void:
	"spawns rain particles and the darkening overlay"
	_rain = CPUParticles2D.new()
	_rain.texture = load("res://backgrounds/raindrop.png")
	_rain.amount = 200
	_rain.lifetime = 3
	_rain.direction = Vector2(0, 1)
	_rain.spread = 5.0
	_rain.gravity = Vector2(200, 450)
	_rain.initial_velocity_min = 150.0
	_rain.initial_velocity_max = 200.0
	_rain.scale_amount_min = 1.5
	_rain.scale_amount_max = 3.0
	_rain.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_rain.emission_rect_extents = Vector2(1000, 10)
	_rain.position = Vector2(500, -100)
	_rain.emitting = true
	_rain.z_index = 25
	add_child(_rain)

	var overlay_layer: CanvasLayer = CanvasLayer.new()
	overlay_layer.layer = 20
	add_child(overlay_layer)

	_rain_overlay = Sprite2D.new()
	_rain_overlay.texture = load("res://backgrounds/rain_overlay.png")
	_rain_overlay.centered = false
	_rain_overlay.modulate = Color(1, 1, 1, 0.6)
	overlay_layer.add_child(_rain_overlay)
	_rain_overlay.set_meta("layer_ref", overlay_layer)

	_rain_back = CPUParticles2D.new()
	_rain_back.texture = load("res://backgrounds/raindrop.png")
	_rain_back.amount = 100
	_rain_back.lifetime = 1.5
	_rain_back.direction = Vector2(0, 1)
	_rain_back.spread = 5.0
	_rain_back.gravity = Vector2(0, 400)
	_rain_back.initial_velocity_min = 150.0
	_rain_back.initial_velocity_max = 250.0
	_rain_back.scale_amount_min = 0.8
	_rain_back.scale_amount_max = 1.2
	_rain_back.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_rain_back.emission_rect_extents = Vector2(1000, 10)
	_rain_back.position = Vector2(_player.position.x, -200)
	_rain_back.modulate = Color(1, 1, 1, 0.3)
	_rain_back.emitting = true
	_rain_back.z_index = -2
	add_child(_rain_back)

	AudioManager.start_rain_sound()


func _stop_rain() -> void:
	"removes rain and overlay"
	if is_instance_valid(_rain):
		_rain.queue_free()
		_rain = null

	if is_instance_valid(_rain_back):
		_rain_back.queue_free()
		_rain_back = null

	if is_instance_valid(_rain_overlay):
		var layer_ref = _rain_overlay.get_meta("layer_ref")
		if is_instance_valid(layer_ref):
			layer_ref.queue_free()
		_rain_overlay = null

	AudioManager.stop_rain_sound()
	_rain_player.stop()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			_toggle_rain()
		elif event.keycode == KEY_T:
			_debug_spawn_barn()
		elif event.keycode == KEY_L:
			AudioManager.play_sfx_test("res://audio/rain_loop.wav")
		elif event.keycode == KEY_M:
			AudioManager.play_sfx_test("res://audio/music/menu_theme.wav")


func _debug_spawn_barn() -> void:
	"debug: force-spawns a barn near the player for testing"
	var path: String = "res://backgrounds/barn.png"
	if not ResourceLoader.exists(path):
		print("Barn texture missing: ", path)
		return
	var barn: Sprite2D = Sprite2D.new()
	barn.texture = load(path)
	barn.centered = false
	barn.position = Vector2(_player.position.x + 200, -50)
	barn.z_index = 0
	add_child(barn)
	print("Debug barn spawned near player")
