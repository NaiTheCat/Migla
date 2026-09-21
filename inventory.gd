extends RefCounted
class_name Inventory


# Inventory class - tracks items collected by the player
# Uses a Dictionary as its core data structure: {item_type: count}

var _items: Dictionary = {}


func get_count(item_type: String) -> int:
	'how many of this type does the player have?'
	if _items.has(item_type):
		return _items[item_type]
	return 0


func get_all() -> Dictionary:
	'returns a copy of the full inventory'
	return _items.duplicate()


func total_items() -> int:
	'total count across all types'
	var total: int = 0
	for count in _items.values():
		total += count
	return total


signal inventory_changed
const MAX_SLOTS: int = 2

func add_item(item_type: String) -> bool:
	'add one item of the given type - returns true if successful'
	if item_type == null or item_type == "":
		push_warning("Tried to add invalid item type")
		return false
	if _items.has(item_type):
		_items[item_type] += 1
	else:
		if _items.size() >= MAX_SLOTS:
			push_warning("Inventory full - can't hold more item types")
			return false
		_items[item_type] = 1
	inventory_changed.emit()
	print("Inventory: ", _items)
	return true

	inventory_changed.emit()
	print("Inventory: ", _items)

func clear_all() -> void:
	"empties the inventory completely"
	_items.clear()
	inventory_changed.emit()
	
