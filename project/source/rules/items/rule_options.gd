@tool
class_name RuleOptions
extends RuleItem
## A game rule that is a choice between some options.


signal value_changed(this_rule: RuleItem)

@export var selected: int = 0:
	set(new_value):
		if _is_locked:
			push_warning("Tried to set property of a locked rule.")
			return
		
		var old_value: int = selected
		selected = new_value
		if selected != old_value:
			value_changed.emit(self)

@export var options: Array[String] = []

## Add to this list's arrays the index of the rules that
## you want to only show when that specific option is selected.
## The 1st array in this list is for the 1st option,
## the 2nd array is for the 2nd option, and so on.
@export var option_filters: Array[PackedInt32Array] = []


func get_data() -> int:
	return selected


func set_data(data: Variant) -> void:
	if data is int:
		selected = data
	elif data is float:
		selected = roundi(data)
	else:
		push_warning("Rule received incorrect type of value.")
