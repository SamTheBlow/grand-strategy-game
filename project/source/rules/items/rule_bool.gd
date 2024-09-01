@tool
class_name RuleBool
extends RuleItem
## A game rule that is a boolean.


signal value_changed(this_rule: RuleItem)

## Set this property in the inspector to set the default value.
@export var value: bool = false:
	set(new_value):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return
		
		var old_value: bool = value
		value = new_value
		if value != old_value:
			value_changed.emit(self)

## Add to this array the index of the rules that you want to
## only show when the [CheckBox] is enabled.[br]
## The index is a position in the [code]sub_rules[/code] array.
@export var sub_rules_on: Array[int] = []
## Add to this array the index of the rules that you want to
## only show when the [CheckBox] is disabled.[br]
## The index is a position in the [code]sub_rules[/code] array.
@export var sub_rules_off: Array[int] = []


func get_data() -> bool:
	return value


func set_data(data: Variant) -> void:
	if data is bool:
		value = data
	else:
		push_warning("Rule received incorrect type of value.")
