extends Area2D
class_name Item

#item class - acts as a collectable

const TYPES: Array = ['mushroom', 'flower', 'stone', 'coin', 'berries'] #ndom array of items

var _item_type: String = "mushroom"
var _collected: bool = false

func setup(item_type: String) -> void:
	'configure this item when spawned'
	if not item_type in TYPES:
		push_warning("Unknown item type: " + item_type)
		item_type = "mushroom"
	_item_type = item_type
	if _item_type == "berries":
		add_to_group("berries_items")
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.randomize()
	_apply_icon()

func _apply_icon() -> void:
	'use custom icon if it exists, otherwise fall back to colour tint'
	var icon_path: String = "res://icons/%s.png" % _item_type
	var sprite: Sprite2D = $Sprite2D
	if ResourceLoader.exists(icon_path):
		sprite.texture = load(icon_path)
		sprite.modulate = Color(1, 1, 1)  # reset tint so icon shows true colour
	else:
		_apply_colour()

func _apply_colour() -> void:
	'tint the sprite based on type - temporary visual, used until icon exists'
	var sprite: Sprite2D = $Sprite2D
	match _item_type:
		"mushroom":
			sprite.modulate = Color(1, 0.3, 0.3)   
		"flower":
			sprite.modulate = Color(1.0, 0.587, 0.811, 1.0)   
		"stone":
			sprite.modulate = Color(0.6, 0.6, 0.6) 
		"coin":
			sprite.modulate = Color(1, 0.85, 0.1)

func get_type() -> String:
	#getter for item type
	return _item_type


func collect() -> void:
	'called when player picks up this item'
	if _collected:
		return
	_collected = true
	queue_free()
	
const ITEM_SPAWN_CHANCE: float = 0.3    #the chance a chunk has an item
const _item_scene: PackedScene = preload("res://item.tscn")

func _ready() -> void:
	z_index = 4
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	


var _player_in_range: Node2D = null

func _on_body_entered(body: Node2D) -> void:
	if _item_type == "berries" and body.has_method("collect_item"):
		_player_in_range = body
		return
	if body.has_method("collect_item"):
		var picked_up: bool = body.collect_item(_item_type)
		if picked_up:
			collect()

func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null

func try_eat() -> bool:
	if _player_in_range != null:
		collect()
		return true
	return false
		
