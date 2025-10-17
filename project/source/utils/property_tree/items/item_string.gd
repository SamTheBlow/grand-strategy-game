@tool
class_name ItemString
extends PropertyTreeItem
## A [PropertyTreeItem] that contains a string value.

signal value_changed(this: PropertyTreeItem)
signal placeholder_text_changed(this: PropertyTreeItem)

## Set this property in the inspector to set the default value.
@export var value: String = "":
	set(new_value):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		if value != new_value:
			value = new_value
			value_changed.emit(self)

## This has no effect and can be changed even after locking the item.
@export var placeholder_text: String = "":
	set(value):
		if placeholder_text != value:
			placeholder_text = value
			placeholder_text_changed.emit(self)


func get_data() -> String:
	return value


func set_data(data: Variant) -> void:
	if data is String:
		value = data
	else:
		push_warning(_INVALID_TYPE_MESSAGE)
