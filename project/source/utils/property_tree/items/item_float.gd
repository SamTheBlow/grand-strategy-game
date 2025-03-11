@tool
class_name ItemFloat
extends PropertyTreeItem
## A [PropertyTreeItem] that contains a float value.

signal value_changed(this: PropertyTreeItem)

## Set this property in the inspector to set the default value.
var value: float = 0:
	set(new_value):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		var old_value: float = value
		value = new_value
		if has_minimum:
			value = maxf(value, minimum)
		if has_maximum:
			value = minf(value, maximum)
		if value != old_value:
			value_changed.emit(self)

## If true, graphical interfaces will display the number as a percentage.
var is_percentage: bool = false:
	set(value):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		is_percentage = value
		notify_property_list_changed()

var has_minimum: bool = false:
	set(new_bool):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		has_minimum = new_bool
		if has_minimum:
			value = maxf(value, minimum)
		notify_property_list_changed()

var minimum: float = 0:
	set(new_min):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		minimum = new_min
		if has_minimum:
			value = maxf(value, minimum)
		# Can't use maxf here because it would cause infinite recursion
		if maximum < minimum:
			maximum = minimum

var has_maximum: bool = false:
	set(new_bool):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		has_maximum = new_bool
		if has_maximum:
			value = minf(value, maximum)
		notify_property_list_changed()

var maximum: float = 0:
	set(new_max):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		maximum = new_max
		if has_maximum:
			value = minf(value, maximum)
		minimum = minf(minimum, maximum)


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []

	properties.append({
		"name": "value",
		"type": TYPE_FLOAT,
	})

	properties.append({
		"name": "is_percentage",
		"type": TYPE_BOOL,
	})

	properties.append({
		"name": "has_minimum",
		"type": TYPE_BOOL,
	})

	var minimum_usage := PROPERTY_USAGE_NO_EDITOR
	if has_minimum:
		minimum_usage = PROPERTY_USAGE_DEFAULT
	properties.append({
		"name": "minimum",
		"type": TYPE_FLOAT,
		"usage": minimum_usage,
	})

	properties.append({
		"name": "has_maximum",
		"type": TYPE_BOOL,
	})

	var maximum_usage := PROPERTY_USAGE_NO_EDITOR
	if has_maximum:
		maximum_usage = PROPERTY_USAGE_DEFAULT
	properties.append({
		"name": "maximum",
		"type": TYPE_FLOAT,
		"usage": maximum_usage,
	})

	return properties


func get_data() -> float:
	return value


func set_data(data: Variant) -> void:
	if data is int:
		value = float(data)
	elif data is float:
		value = data
	else:
		push_warning(_INVALID_TYPE_MESSAGE)
