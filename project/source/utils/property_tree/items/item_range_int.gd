@tool
class_name ItemRangeInt
extends PropertyTreeItem
## A [PropertyTreeItem] that contains a range of integer values.

signal value_changed(this: PropertyTreeItem)

var min_value: int = 0:
	set(value):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		var old_value: int = min_value
		min_value = value
		if min_item:
			min_item.value = value
		if max_value < min_value:
			max_value = min_value
		elif min_value != old_value:
			value_changed.emit(self)

var max_value: int = 0:
	set(value):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		var old_value: int = max_value
		max_value = value
		if max_item:
			max_item.value = value
		if max_value < min_value:
			min_value = max_value
		elif max_value != old_value:
			value_changed.emit(self)

var has_minimum: bool = false:
	set(new_bool):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		has_minimum = new_bool
		if has_minimum:
			min_value = maxi(min_value, minimum)

## How low this range's min_value is allowed to go
var minimum: int = 0:
	set(new_min):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		minimum = new_min
		if has_minimum:
			min_value = maxi(min_value, minimum)
		# Can't use maxi here because it would cause infinite recursion
		if maximum < minimum:
			maximum = minimum

var has_maximum: bool = false:
	set(new_bool):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		has_maximum = new_bool
		if has_maximum:
			max_value = mini(max_value, maximum)

## How high this range's max_value is allowed to go
var maximum: int = 0:
	set(new_max):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		maximum = new_max
		if has_maximum:
			max_value = mini(max_value, maximum)
		minimum = mini(minimum, maximum)

# 4.0 backwards compatibility
var min_item: ItemInt:
	set(value):
		min_item = value
		min_item.value_changed.connect(_on_min_value_changed)
var max_item: ItemInt:
	set(value):
		max_item = value
		max_item.value_changed.connect(_on_max_value_changed)


## Returns the value that's the same distance from min_value and max_value.
func average() -> float:
	return (max_value - min_value) * 0.5


func get_data() -> Array:
	return [min_value, max_value]


## Input data should be an array containing exactly two numbers.
func set_data(data: Variant) -> void:
	if data is not Array:
		push_warning(_INVALID_TYPE_MESSAGE)
		return
	var data_array: Array = data

	if data_array.size() != 2:
		push_warning("Received array of incorrect size.")
		return
	if not ParseUtils.is_number(data_array[0]):
		push_warning("Range minimum is not a number.")
		return
	if not ParseUtils.is_number(data_array[1]):
		push_warning("Range maximum is not a number.")
		return

	min_value = ParseUtils.number_as_int(data_array[0])
	max_value = ParseUtils.number_as_int(data_array[1])


func _on_min_value_changed(_item: PropertyTreeItem) -> void:
	min_value = min_item.value


func _on_max_value_changed(_item: PropertyTreeItem) -> void:
	max_value = max_item.value
