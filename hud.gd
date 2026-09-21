extends CanvasLayer
class_name Hud

@export var _player: Node2D
@onready var _distance_label: Label = $DistanceLabel
@onready var _eat_hint: Label = $EatHint

func _ready() -> void:
	_eat_hint.visible = false
	_eat_hint.text = "Press E to eat"
	pass

func _process(_delta: float) -> void:
	if _player != null:
		var distance: int = int(_player.position.x)
		_distance_label.text = "Distance: %d" % distance
	_update_eat_hint()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_G:
			_drop_items()
		elif event.keycode == KEY_E:
			_eat_berries()



func _drop_items() -> void:
	"drops all inventory items back into the world near the player"
	var inventory: Inventory = _player.get_inventory()
	var items: Dictionary = inventory.get_all()
	for item_type in items:
		var count: int = items[item_type]
		for i in range(count):
			_spawn_dropped_item(item_type)
	inventory.clear_all()

func _spawn_dropped_item(item_type: String) -> void:
	"creates a pickup-able item near the player"
	var item_scene: PackedScene = preload("res://item.tscn")
	var new_item: Item = item_scene.instantiate()
	_player.get_parent().add_child(new_item)
	new_item.global_position = _player.global_position + Vector2(randf_range(-40, 40), -20)
	new_item.setup(item_type)
	
func _eat_berries() -> void:
	"eats a nearby world berry directly, no inventory involved"
	var berries: Array = get_tree().get_nodes_in_group("berries_items")
	for berry in berries:
		if berry.global_position.distance_to(_player.global_position) < 40:
			if berry.try_eat():
				print("Ate a wild berry!")
				AudioManager.play_sfx("eat")
				_hint_shown_count += 1
				return
	print("No berries nearby to eat")


var _hint_shown_count: int = 0
const MAX_HINT_SHOWS: int = 5

func _update_eat_hint() -> void:
	"shows a prompt when standing near a berry bush, only for the first 5 times"
	if _hint_shown_count >= MAX_HINT_SHOWS:
		_eat_hint.visible = false
		return

	var berries: Array = get_tree().get_nodes_in_group("berries_items")
	var near_berry: bool = false
	for berry in berries:
		if is_instance_valid(berry) and berry.global_position.distance_to(_player.global_position) < 40:
			near_berry = true
			break
	_eat_hint.visible = near_berry
	_eat_hint.position = Vector2(800, 500)
