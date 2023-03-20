class_name RuleAutoRecruit
extends Rule
# Gives a set amount of troops to each army at the start of each turn


@export var army_scene: PackedScene


func _on_start_of_turn(provinces: Array[Province], _current_turn: int):
	for province in provinces:
		if province.owner_country:
			var new_army := army_scene.instantiate() as Army
			new_army.owner_country = province.owner_country
			var population_node := province.get_node("Population") as Population
			new_army.troop_count = population_node.population_count
			var armies_node := province.get_node("Armies") as Armies
			armies_node.add_army(new_army)
			armies_node.merge_armies()
