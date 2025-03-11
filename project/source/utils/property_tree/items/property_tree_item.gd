@tool
class_name PropertyTreeItem
extends Resource
## Base class for an item to use in a property tree.
## Extend this class to add functionality.
##
## Note: this is unrelated to the built-in class [Tree].

const _LOCKED_ITEM_MESSAGE: String = "Tried to set property of a locked item."
const _INVALID_TYPE_MESSAGE: String = "Received invalid value type."

## The text to show on the tree for this item.
@export var text: String = ""

## The items to show on the tree as children of this item. The order matters.
@export var child_items: Array[PropertyTreeItem] = []

var _is_locked: bool = false


## Locks this item and (recursively) all of its children. Cannot be undone.
## When an item is locked, its data cannot be changed anymore.
func lock() -> void:
	_is_locked = true
	for sub_rule in child_items:
		sub_rule.lock()


## This item's data, for the purpose of saving/loading.
## Returns null if it contains no data.
func get_data() -> Variant:
	return null


func set_data(_data: Variant) -> void:
	pass
