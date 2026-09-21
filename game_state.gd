extends Node

var current_game_id: int = -1
var current_username: String = ""

func _ready() -> void:
	_spawn_whimsy_overlay()

func _spawn_whimsy_overlay() -> void:
	"adds a decorative vine frame that persists across every scene"
	var path: String = "res://backgrounds/whimsy_overlay.png"
	if not ResourceLoader.exists(path):
		return
	var whimsy_layer: CanvasLayer = CanvasLayer.new()
	whimsy_layer.layer = 30
	add_child(whimsy_layer)
	var overlay: Sprite2D = Sprite2D.new()
	overlay.texture = load(path)
	overlay.centered = false
	whimsy_layer.add_child(overlay)
