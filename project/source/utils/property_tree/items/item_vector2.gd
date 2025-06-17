@tool
class_name ItemVector2
extends PropertyTreeItem
## A [PropertyTreeItem] that contains a [Vector2] value.

signal value_changed(this: PropertyTreeItem)

var value_x: float:
	get:
		return _value.x
	set(new_value):
		_value.x = new_value

var value_y: float:
	get:
		return _value.y
	set(new_value):
		_value.y = new_value

## Set this property in the inspector to set the default value.
@export var _value := Vector2.ZERO:
	set(new_value):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		var old_value: Vector2 = _value
		_value = new_value
		if _value != old_value:
			value_changed.emit(self)

## The suffix to add at the end (e.g. "10px", "10°").
@export var suffix: String = ""


func get_data() -> Vector2:
	return _value


func set_data(data: Variant) -> void:
	if data is Array:
		var array: Array = data
		if array.size() != 2:
			return
		if ParseUtils.is_number(array[0]) and ParseUtils.is_number(array[1]):
			_value = Vector2(
					ParseUtils.number_as_float(array[0]),
					ParseUtils.number_as_float(array[1])
			)
	elif data is Vector2:
		_value = data
	else:
		push_warning(_INVALID_TYPE_MESSAGE)
