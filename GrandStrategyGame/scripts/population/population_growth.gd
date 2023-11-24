class_name PopulationGrowth
extends Node
## Add this as a child of a Population node.
## At the start of each turn, increases the population size exponentially.


func _on_new_turn() -> void:
	var parent: Node = get_parent()
	
	if not parent or not (parent is Population):
		return
	
	var population := parent as Population
	population.population_size += int(population.population_size * 0.1)
