# Basic rule for testing
# Increases a province's population at an exponential rate
extends Rule
class_name RulePopGrowth

func _on_start_of_turn(provinces, _current_turn):
	for province in provinces:
		var population:int = province.get_node("Population").population_count
		province.get_node("Population").population_count += population >> 1
