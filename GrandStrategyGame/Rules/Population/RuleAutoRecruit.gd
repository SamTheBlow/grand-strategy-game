class_name RuleAutoRecruit
extends Rule
# Gives a set amount of troops to each army at the start of each turn


@export var army_scene: PackedScene


func _on_start_of_turn(game_state: GameState):
	var provinces_node: Provinces = (
		get_parent().get_parent().get_node("Provinces") as Provinces
	)
	
	var provinces: Array[GameStateData] = game_state.provinces().data()
	for province_data in provinces:
		var province := province_data as GameStateArray
		var province_owner := String(province.get_string("owner").data)
		if province_owner != "-1":
			# Internal change
			var province_population: int = province.get_int("population").data
			var new_army_data: Array[GameStateData] = [
				GameStateString.new("owner", String(province_owner)),
				GameStateInt.new("troop_count", province_population),
			]
			var new_army := GameStateArray.new(
				province.new_unique_key(), new_army_data, false
			)
			province.get_array("armies").data().append(new_army)
			# Bad code!!!
			get_tree().current_scene.merge_armies(province.get_array("armies").data())
			
			# Visual change
			var new_army_node := army_scene.instantiate() as Army
			var province_node: Province = (
				provinces_node.province_with_key(province.get_key())
			)
			new_army_node.owner_country = province_node.owner_country
			new_army_node.troop_count = province_population
			new_army_node._key = new_army.get_key()
			var armies_node := province_node.get_node("Armies") as Armies
			armies_node.add_army(new_army_node)
			armies_node.merge_armies()
