class_name ModifierList
## Provides utility functions on an encapsulated list of modifiers.

var _modifiers: Array[Modifier]


func _init(modifiers: Array[Modifier]) -> void:
	_modifiers = modifiers


## Returns what a given value becomes after is it affected by each modifier.
func resulti(base_value: int = 0) -> int:
	var output: int = base_value

	for modifier in _modifiers:
		output = modifier.applyi(output)

	return output


## Returns what a given value becomes after is it affected by each modifier.
func resultf(base_value: float = 1.0) -> float:
	var output: float = base_value

	#print("===== Calculating final modifier! Base value: %s" % output)
	for modifier in _modifiers:
		output = modifier.applyf(output)
		#print("===== Now at %s because of %s" % [output, modifier._description])
	#print("===== Final modifier: %s" % output)

	return output
