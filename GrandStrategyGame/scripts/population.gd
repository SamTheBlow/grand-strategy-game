class_name Population
extends Node


## Must be positive or zero
var population_size: int


func as_JSON() -> Dictionary:
	return {
		"size": population_size,
	}
