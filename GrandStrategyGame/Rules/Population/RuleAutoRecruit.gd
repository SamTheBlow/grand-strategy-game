# Gives a set amount of troops to each army at the start of each turn
extends Rule
class_name RuleAutoRecruit

@export var army_scene:PackedScene

func _on_start_of_turn(provinces:Array[Province], _current_turn:int):
	for province in provinces:
		if province.owner_country != null:
			var new_army = army_scene.instantiate()
			new_army.owner_country = province.owner_country
			new_army.troop_count = province.get_node("Population").population_count
			province.get_node("Armies").add_army(new_army)
			province.get_node("Armies").merge_armies()
