@tool
class_name ItemBool
extends PropertyTreeItem
## A [PropertyTreeItem] that contains a boolean value.

signal value_changed(this: PropertyTreeItem)

## Set this property in the inspector to set the default value.
@export var value: bool = false:
	set(new_value):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		if value != new_value:
			value = new_value
			value_changed.emit(self)

## Add to this array the index of items you want to
## only show when the boolean value is set to true.[br]
## The index is a position in the [code]child_items[/code] array.
@export var child_items_on: Array[int] = []
## Add to this array the index of items you want to
## only show when the boolean value is set to false.[br]
## The index is a position in the [code]child_items[/code] array.
@export var child_items_off: Array[int] = []


func get_data() -> bool:
	return value


func set_data(data: Variant) -> void:
	if data is bool:
		value = data
	else:
		push_warning(_INVALID_TYPE_MESSAGE)
