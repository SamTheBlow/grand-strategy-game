class_name ModifierMultiplier
extends Modifier
## This [Modifier] multiplies some base value by some multiplier.


var _multiplier: float = 1.0


func _init(description: String, hint: String, multiplier: float) -> void:
	super(description, hint)
	_multiplier = multiplier


## Override
func shown_value() -> String:
	return "x" + str(_multiplier)


## Override
##
## Rounds down.
func applyi(input: int) -> int:
	return floori(input * _multiplier)


## Override
func applyf(input: float) -> float:
	return input * _multiplier
