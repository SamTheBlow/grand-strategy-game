@tool
class_name RuleFloat
extends RuleItem
## A game rule that is a float value.

signal value_changed(this_rule: RuleItem)

## Set this property in the inspector to set the default value.
var value: float = 0:
	set(new_value):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return

		var old_value: float = value
		value = new_value
		if has_minimum:
			value = maxf(value, minimum)
		if has_maximum:
			value = minf(value, maximum)
		if value != old_value:
			value_changed.emit(self)

var has_minimum: bool = false:
	set(new_bool):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return

		has_minimum = new_bool
		if has_minimum:
			value = maxf(value, minimum)
		notify_property_list_changed()

var minimum: float = 0:
	set(new_min):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return

		minimum = new_min
		if has_minimum:
			value = maxf(value, minimum)
		# Can't use maxi here because it would cause infinite recursion
		if maximum < minimum:
			maximum = minimum

var has_maximum: bool = false:
	set(new_bool):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return

		has_maximum = new_bool
		if has_maximum:
			value = minf(value, maximum)
		notify_property_list_changed()

var maximum: float = 0:
	set(new_max):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return

		maximum = new_max
		if has_maximum:
			value = minf(value, maximum)
		minimum = minf(minimum, maximum)

## This only serves to show this value as a percentage in interfaces
var is_percentage: bool = false


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []

	properties.append({
		"name": "value",
		"type": TYPE_FLOAT,
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
		push_warning("Rule received incorrect type of value.")
