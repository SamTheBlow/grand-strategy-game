class_name RulePopGrowth
extends Rule
# Basic rule for testing
# Increases a province's population at an exponential rate


func _on_start_of_turn(provinces: Array[Province], _current_turn: int):
	for province in provinces:
		var population_node := province.get_node("Population") as Population
		var population_count: int = population_node.population_count
		population_node.population_count += int(population_count * 0.1)
