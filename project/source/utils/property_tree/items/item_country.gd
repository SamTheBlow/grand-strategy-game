@tool
class_name ItemCountry
extends PropertyTreeItem
## A [PropertyTreeItem] that contains a [Country] value.

signal value_changed(this: PropertyTreeItem)
signal change_requested()

var value: Country = null:
	set(new_value):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		if value != new_value:
			value = new_value
			value_changed.emit(self)


func request_change() -> void:
	change_requested.emit()
