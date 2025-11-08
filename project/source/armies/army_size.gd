class_name ArmySize
## An [int] that has a minimum and, optionally, a maximum.
## The minimum value may not be less than 1.

## Emitted whenever the value changes.
signal changed(new_value: int)
## Emitted when the value is set to less than the minimum.
signal became_too_small()
## Emitted when the value is set to more than the maximum.
signal became_too_large()

var value: int = 1:
	set(new_value):
		if new_value == value:
			return

		# Respect maximum size
		if has_maximum() and new_value > maximum_value:
			value = maximum_value
			became_too_large.emit()

		# Respect minimum size
		elif new_value < minimum_value:
			value = minimum_value
			became_too_small.emit()

		else:
			value = new_value

		changed.emit(value)

## Cannot be less than 1.
var minimum_value: int = 1:
	set(new_value):
		minimum_value = maxi(1, new_value)

## If the maximum value is less than 1, then there is no maximum value.
var maximum_value: int = 0:
	set(new_value):
		maximum_value = maxi(0, new_value)


func _init(
		starting_value: int = 1,
		starting_minimum: int = 1,
		starting_maximum: int = 0
) -> void:
	minimum_value = starting_minimum
	maximum_value = starting_maximum
	value = starting_value


func has_maximum() -> bool:
	return maximum_value > 0
