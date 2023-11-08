class_name Population
extends Node


## Must be positive or zero
var population_size: int


func _on_new_turn() -> void:
	# Simulate population growth
	population_size += int(population_size * 0.1)


func as_JSON() -> Dictionary:
	return {
		"size": population_size,
	}
