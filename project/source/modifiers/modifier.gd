class_name Modifier
## Abstract class for modifiers.
##
## A modifier is simply an effect that is applied onto some number.

var _description: String
var _hint: String


func _init(description: String, hint: String) -> void:
	_description = description
	_hint = hint


## To be overridden.
##
## Returns a string representation of this modifier's effect.
func shown_value() -> String:
	push_warning("Modifier does not have a string representation.")
	return ""


## To be overridden.
##
## Returns the new value after applying this modifier's effect.
func applyi(input: int) -> int:
	push_warning("Modifier has no defined effect on integer inputs.")
	return input


## To be overridden.
##
## Returns the new value after applying this modifier's effect.
func applyf(input: float) -> float:
	push_warning("Modifier has no defined effect on float inputs.")
	return input
