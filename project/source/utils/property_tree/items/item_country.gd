@tool
class_name ItemCountry
extends PropertyTreeItem
## A [PropertyTreeItem] that contains a [Country] value.

signal value_changed(this: PropertyTreeItem)
signal change_requested(this: ItemCountry)

var value: Country = null:
	set(new_value):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return
		elif not _may_be_null and new_value == null:
			push_error("Country value may not be null.")
			return
		elif value == new_value:
			return

		value = new_value
		value_changed.emit(self)

var _may_be_null: bool = true


func set_value(new_value: Country) -> void:
	value = new_value


func may_be_null() -> bool:
	return _may_be_null


## Makes it so that this item's value may not be null.
## You must provide a non-null value to set it to.
func make_unnullable(new_value: Country) -> void:
	_may_be_null = false
	value = new_value


func request_change() -> void:
	change_requested.emit(self)
