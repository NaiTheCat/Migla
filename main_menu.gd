extends Control
class_name MainMenu

@onready var _title: Label = $VBoxContainer/Title
@onready var _new_game_btn: Button = $VBoxContainer/NewGameButton
@onready var _load_game_btn: Button = $VBoxContainer/LoadGameButton
@onready var _username_input: LineEdit = $VBoxContainer/UsernameInput
@onready var _confirm_btn: Button = $VBoxContainer/ConfirmButton
@onready var _save_list: ItemList = $VBoxContainer/SaveList

@onready var _controls_button: Button = $VBoxContainer/ControlsButton
@onready var _controls_text: Label = $VBoxContainer/ControlsText
@onready var _back_button: Button = $VBoxContainer/BackButton

var _db: Database
var _game_ids: Array = []   # maps list index -> game_id

func _ready() -> void:
	_db = Database.new()
	add_child(_db)
	_title.text = "Migla"
	_username_input.visible = false
	_confirm_btn.visible = false
	_save_list.visible = false
	_new_game_btn.pressed.connect(_on_new_game_pressed)
	_load_game_btn.pressed.connect(_on_load_game_pressed)
	_confirm_btn.pressed.connect(_on_confirm_pressed)
	_save_list.item_selected.connect(_on_save_selected)
	print("Save path: ", OS.get_user_data_dir())
	_add_background()
	_add_menu_clouds()
	
	_username_input.visible = false
	_confirm_btn.visible = false
	_save_list.visible = false
	_controls_text.visible = false
	_back_button.visible = false
	_new_game_btn.pressed.connect(_on_new_game_pressed)
	_load_game_btn.pressed.connect(_on_load_game_pressed)
	_confirm_btn.pressed.connect(_on_confirm_pressed)
	_save_list.item_selected.connect(_on_save_selected)
	_controls_button.pressed.connect(_on_controls_pressed)
	_back_button.pressed.connect(_on_back_pressed)

func _on_new_game_pressed() -> void:
	"show username entry"
	_username_input.visible = true
	_confirm_btn.visible = true
	_back_button.visible = true
	_new_game_btn.visible = false
	_load_game_btn.visible = false
	_controls_button.visible = false

func _on_confirm_pressed() -> void:
	"create the save and start the game"
	var username: String = _username_input.text.strip_edges()
	if username == "":
		return
	var game_id: int = _db.create_game(username)
	_start_game(game_id)

func _on_load_game_pressed() -> void:
	var games: Array = _db.get_all_games()
	_save_list.clear()
	_game_ids.clear()
	for game in games:
		var label: String = "%s - Distance: %d" % [game["username"], game["furthest_distance"]]
		_save_list.add_item(label)
		_game_ids.append(int(game["game_id"]))
	_save_list.visible = true
	_back_button.visible = true
	_new_game_btn.visible = false
	_load_game_btn.visible = false
	_controls_button.visible = false

func _on_save_selected(index: int) -> void:
	"load whichever save was clicked"
	var game_id: int = _game_ids[index]
	_start_game(game_id)

func _start_game(game_id: int) -> void:
	"hands off to the main game scene, passing which save is active"
	GameState.current_game_id = game_id
	get_tree().change_scene_to_file("res://main.tscn")
	
func _add_background() -> void:
	var path: String = "res://backgrounds/menu_bg.png"
	if not ResourceLoader.exists(path):
		return
	var bg: TextureRect = TextureRect.new()
	bg.texture = load(path)
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(bg)
	move_child(bg, 0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	bg.z_index = -10
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

var _menu_clouds: Array = []
const MENU_CLOUD_SPEED: float = 10.0

func _add_menu_clouds() -> void:
	"adds a couple of decorative clouds to the menu screen"
	var cloud_positions: Array = [Vector2(100, -425), Vector2(1500, -475), Vector2(800, -450)]
	for pos in cloud_positions:
		var variant: int = randi_range(1, 2)
		var path: String = "res://backgrounds/cloud_bg_%d.png" % variant
		if not ResourceLoader.exists(path):
			continue
		var cloud: TextureRect = TextureRect.new()
		cloud.texture = load(path)
		cloud.anchor_left = 0
		cloud.anchor_top = 0
		cloud.anchor_right = 0
		cloud.anchor_bottom = 0
		cloud.position = pos
		cloud.z_index = -5
		cloud.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		cloud.scale = Vector2(3.0, 3.0)  # adjust to taste
		add_child(cloud)
		_menu_clouds.append(cloud)

func _process(delta: float) -> void:
	for cloud in _menu_clouds:
		if is_instance_valid(cloud):
			cloud.position.x += MENU_CLOUD_SPEED * delta
			
func _show_main_buttons() -> void:
	"resets to the main menu buttons only"
	_new_game_btn.visible = true
	_load_game_btn.visible = true
	_controls_button.visible = true
	_username_input.visible = false
	_confirm_btn.visible = false
	_save_list.visible = false
	_controls_text.visible = false
	_back_button.visible = false
	
func _on_controls_pressed() -> void:
	_controls_text.text = "Arrow keys / A-D: move\nUp: jump\nB: open backpack\nG: drop items\nE: eat berries\nR: toggle rain (debug)"
	_controls_text.visible = true
	_back_button.visible = true
	_new_game_btn.visible = false
	_load_game_btn.visible = false
	_controls_button.visible = false
	

func _on_back_pressed() -> void:
	_show_main_buttons()
