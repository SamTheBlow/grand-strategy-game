# Gives a set amount of troops to each army at the start of each turn
extends Rule
class_name RuleAutoRecruit

func _on_start_of_turn(provinces, _current_turn):
	for province in provinces:
		var armies = province.get_node("Armies").get_alive_armies()
		var population = province.get_node("Population").population_count
		for army in armies:
			army.troop_count += population
