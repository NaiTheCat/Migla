extends Node
class_name Database

var _db: SQLite

const DB_PATH: String = "user://game_data"

func _ready() -> void:
	_db = SQLite.new()
	_db.path = DB_PATH
	_db.open_db()
	_create_tables()

func _create_tables() -> void:
	"sets up the games table if it doesn't exist yet"
	var table_def: Dictionary = {
		"game_id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true},
		"username": {"data_type": "text", "not_null": true},
		"furthest_distance": {"data_type": "int"},
		"inventory": {"data_type": "text"}
	}
	_db.create_table("games", table_def)
	
func create_game(username: String) -> int:
	"creates a new save under this username, returns the new game_id"
	_db.insert_row("games", {"username": username, "furthest_distance": 0})
	var result: Array = _db.select_rows("games", "username = '%s'" % username, ["game_id"])
	return int(result[-1]["game_id"])  # most recent match

func get_all_games() -> Array:
	"returns every saved game - for the Load Game screen"
	return _db.select_rows("games", "", ["game_id", "username", "furthest_distance"])

func save_progress(game_id: int, distance: int) -> void:
	"updates furthest distance for a specific save"
	var existing: Array = _db.select_rows("games", "game_id = %d" % game_id, ["furthest_distance"])
	if existing.size() > 0 and distance > int(existing[0]["furthest_distance"]):
		_db.update_rows("games", "game_id = %d" % game_id, {"furthest_distance": distance})

func get_game(game_id: int) -> Dictionary:
	"loads a specific save's data"
	var result: Array = _db.select_rows("games", "game_id = %d" % game_id, ["*"])
	if result.size() > 0:
		return result[0]
	return {}

func save_inventory(game_id: int, inventory_data: Dictionary) -> void:
	"saves the player's inventory as a JSON string"
	var json_string: String = JSON.stringify(inventory_data)
	_db.update_rows("games", "game_id = %d" % game_id, {"inventory": json_string})

func load_inventory(game_id: int) -> Dictionary:
	"loads the player's inventory back from JSON"
	var result: Array = _db.select_rows("games", "game_id = %d" % game_id, ["inventory"])
	if result.size() > 0 and result[0]["inventory"] != null and result[0]["inventory"] != "":
		var json: JSON = JSON.new()
		json.parse(result[0]["inventory"])
		return json.data
	return {}
