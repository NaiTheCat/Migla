extends CanvasLayer
class_name Backpack

@export var _player: Node2D
@onready var _panel: Panel = $Panel
@onready var _grid: GridContainer = $Panel/GridContainer
var _inventory: Inventory

const SLOT_SIZE: int = 40
const SLOT_MARGIN: int = 4
const COLUMNS: int = 2
const ROWS: int = 1  
const OFFSET: Vector2 = Vector2(-46, -100)   # centered above player, higher up

func _ready() -> void:
	visible = false
	_inventory = _player.get_inventory()
	_inventory.inventory_changed.connect(_refresh)
	_grid.columns = COLUMNS
	_panel.custom_minimum_size = Vector2(
		COLUMNS * (SLOT_SIZE + SLOT_MARGIN) + SLOT_MARGIN,
		ROWS * (SLOT_SIZE + SLOT_MARGIN) + SLOT_MARGIN
	)
	_apply_background()
	
func _apply_background() -> void:
	var bg_path: String = "res://backgrounds/backpack_bg.png"
	if ResourceLoader.exists(bg_path):
		var style: StyleBoxTexture = StyleBoxTexture.new()
		style.texture = load(bg_path)
		_panel.add_theme_stylebox_override("panel", style)

func _process(_delta: float) -> void:
	if visible:
		_follow_player()

func _follow_player() -> void:
	var screen_pos: Vector2 = get_viewport().get_canvas_transform() * _player.global_position
	_panel.position = screen_pos + OFFSET

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_backpack"):
		visible = not visible

func _refresh() -> void:
	for child in _grid.get_children():
		child.queue_free()
	for item_type in _inventory.get_all():
		var slot: Panel = _make_slot(item_type, _inventory.get_count(item_type))
		_grid.add_child(slot)

func _make_slot(item_type: String, count: int) -> Panel:
	var slot: Panel = Panel.new()
	slot.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
	
	var empty_style: StyleBoxEmpty = StyleBoxEmpty.new()
	slot.add_theme_stylebox_override("panel", empty_style)

	var icon_path: String = "res://icons/%s.png" % item_type
	var icon: Control
	if ResourceLoader.exists(icon_path):
		var tex_rect: TextureRect = TextureRect.new()
		tex_rect.texture = load(icon_path)
		tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon = tex_rect
	else:
		var rect: ColorRect = ColorRect.new()
		rect.color = _colour_for(item_type)
		icon = rect
	icon.custom_minimum_size = Vector2(SLOT_SIZE - 8, SLOT_SIZE - 8)
	icon.position = Vector2(4, 4)
	slot.add_child(icon)

	var label: Label = Label.new()
	label.text = str(count)
	label.position = Vector2(SLOT_SIZE - 16, SLOT_SIZE - 16)
	slot.add_child(label)

	return slot

func _colour_for(item_type: String) -> Color:
	match item_type:
		"mushroom": return Color(1, 0.3, 0.3)
		"flower": return Color(1.0, 0.587, 0.811)
		"stone": return Color(0.6, 0.6, 0.6)
		"coin": return Color(1, 0.85, 0.1)
		_: return Color.WHITE
