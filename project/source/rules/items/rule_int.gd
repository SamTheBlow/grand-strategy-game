class_name RuleInt
extends RuleItem
## A game rule that is an integer value.


signal value_changed(this_rule: RuleItem)

## Set this property in the inspector to set the default value.
var value: int = 0:
	set(new_value):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return
		
		var old_value: int = value
		value = new_value
		if has_minimum:
			value = maxi(value, minimum)
		if has_maximum:
			value = mini(value, maximum)
		if value != old_value:
			value_changed.emit(self)

var has_minimum: bool = false:
	set(new_bool):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return
		
		has_minimum = new_bool
		if has_minimum:
			value = maxi(value, minimum)
		notify_property_list_changed()

var minimum: int = 0:
	set(new_min):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return
		
		minimum = new_min
		if has_minimum:
			value = maxi(value, minimum)
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
			value = mini(value, maximum)
		notify_property_list_changed()

var maximum: int = 0:
	set(new_max):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return
		
		maximum = new_max
		if has_maximum:
			value = mini(value, maximum)
		minimum = mini(minimum, maximum)


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	properties.append({
		"name": "value",
		"type": TYPE_INT,
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
		"type": TYPE_INT,
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
		"type": TYPE_INT,
		"usage": maximum_usage,
	})
	
	return properties


func get_data() -> int:
	return value


func set_data(data: Variant) -> void:
	if data is int:
		value = data
	elif data is float:
		value = roundi(data)
	else:
		push_warning("Rule received incorrect type of value.")
