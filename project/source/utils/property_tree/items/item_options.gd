@tool
class_name ItemOptions
extends PropertyTreeItem
## A [PropertyTreeItem] that contains a choice between some options.

signal value_changed(this: PropertyTreeItem)

## The index of the selection option in the options array.
@export var selected_index: int = 0:
	set(new_index):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		if new_index == selected_index:
			return

		if (
				options.size() > 0
				and (new_index < 0 or new_index >= options.size())
		):
			push_warning(
					"Tried to set the selected index to an invalid value."
			)
			return

		selected_index = new_index
		value_changed.emit(self)

## The different options available to the user.
@export var options: Array[String] = []

## Maps each option to a number. Useful when working with enums.
## For example, you can map the 1st option to the number 45,
## so when the 1st option is selected, the selected value is 45.
## Has no effect if the array's size is not the same as the number of options.
@export var option_value_map: Array[int] = []

## Add to this list's arrays the index of items that
## you want to only show when that specific option is selected.
## The 1st array in this list is for the 1st option,
## the 2nd array is for the 2nd option, and so on.
@export var option_filters: Array[PackedInt32Array] = []


## Returns the selected value (see "option_value_map").
## If the option value map is not set up or if it is set up incorrectly,
## returns the selected index instead.
func selected_value() -> int:
	if (
			option_value_map.size() != options.size()
			or selected_index >= option_value_map.size()
	):
		return selected_index

	return option_value_map[selected_index]


## Converts a mapped value to an option index (see "option_value_map").
## If given value is invalid, returns 0.
func index_of_value(value: int) -> int:
	var index: int = option_value_map.find(value)
	return index if index != -1 else 0


func get_data() -> int:
	return selected_index


func set_data(data: Variant) -> void:
	if data is int:
		selected_index = data
	elif data is float:
		selected_index = roundi(data)
	else:
		push_warning(_INVALID_TYPE_MESSAGE)
