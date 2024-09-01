class_name ModifierPercentage
extends Modifier
## This has the same effect as a [ModifierMultiplier],
## but the effect is shown as a percentage instead.


var _multiplier: float = 1.0


func _init(description: String, hint: String, multiplier: float) -> void:
	super(description, hint)
	_multiplier = multiplier


## Override
func shown_value() -> String:
	return "+" + str((_multiplier - 1.0) * 100.0) + "%"


## Override
##
## Rounds down.
func applyi(input: int) -> int:
	return floori(input * _multiplier)


## Override
func applyf(input: float) -> float:
	return input * _multiplier
