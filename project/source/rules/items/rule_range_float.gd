@tool
class_name RuleRangeFloat
extends RuleItem
## A game rule that is a range of float values.

signal value_changed(this_rule: RuleItem)

var min_value: float = 0:
	set(value):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return

		var old_value: float = min_value
		min_value = value
		if min_rule:
			min_rule.value = value
		if max_value < min_value:
			max_value = min_value
		elif min_value != old_value:
			value_changed.emit(self)

var max_value: float = 0:
	set(value):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return

		var old_value: float = max_value
		max_value = value
		if max_rule:
			max_rule.value = value
		if max_value < min_value:
			min_value = max_value
		elif max_value != old_value:
			value_changed.emit(self)

var has_minimum: bool = false:
	set(new_bool):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return

		has_minimum = new_bool
		if has_minimum:
			min_value = maxf(min_value, minimum)

## How low this range's min_value is allowed to go
var minimum: float = 0:
	set(new_min):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return

		minimum = new_min
		if has_minimum:
			min_value = maxf(min_value, minimum)
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
			max_value = minf(max_value, maximum)

## How high this range's max_value is allowed to go
var maximum: float = 0:
	set(new_max):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return

		maximum = new_max
		if has_maximum:
			max_value = minf(max_value, maximum)
		minimum = minf(minimum, maximum)

# 4.0 backwards compatibility
var min_rule: RuleFloat:
	set(value):
		min_rule = value
		min_rule.value_changed.connect(_on_rule_min_value_changed)
var max_rule: RuleFloat:
	set(value):
		max_rule = value
		max_rule.value_changed.connect(_on_rule_max_value_changed)


func get_data() -> Array:
	return [min_value, max_value]


## Must pass an array containing exactly two float values,
## otherwise nothing will happen.
func set_data(data: Variant) -> void:
	if not (data is Array):
		push_warning("Rule received incorrect type of value.")
		return
	var data_array := data as Array

	if data_array.size() != 2:
		push_warning("Range rule received array of incorrect size.")
		return

	var data_minimum: Variant = data_array[0]
	var final_minimum: float = 0

	if data_minimum is int:
		final_minimum = float(data_minimum)
	elif data_minimum is float:
		final_minimum = data_minimum
	else:
		push_warning("Range rule minimum is incorrect type of value.")
		return

	var data_maximum: Variant = data_array[1]
	var final_maximum: float = 0

	if data_maximum is int:
		final_maximum = float(data_maximum)
	elif data_maximum is float:
		final_maximum = data_maximum
	else:
		push_warning("Range rule maximum is incorrect type of value.")
		return

	min_value = final_minimum
	max_value = final_maximum


func _on_rule_min_value_changed(_rule: RuleItem) -> void:
	min_value = min_rule.value


func _on_rule_max_value_changed(_rule: RuleItem) -> void:
	max_value = max_rule.value
