class_name Population
## Contains a population size as a number.

signal size_changed(new_value: int)

## Must be positive or zero.
var population_size: int = 0:
	set(value):
		if value < 0:
			push_warning("Tried to set population to negative value.")
			value = 0

		var previous_value: int = population_size
		population_size = value
		if value != previous_value:
			size_changed.emit(value)


func _init(starting_size: int = 0) -> void:
	population_size = starting_size
