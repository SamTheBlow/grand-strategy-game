class_name Population
extends Node


signal size_changed(new_value: int)

## Must be positive or zero
var population_size: int : set = set_size


func set_size(value: int) -> void:
	population_size = value
	size_changed.emit(value)
