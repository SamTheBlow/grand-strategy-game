class_name RuleAutoRecruit
extends Rule
# Gives a set amount of troops to each army at the start of each turn


func _on_start_of_turn(game_state: GameState) -> void:
	for province in game_state.world.provinces.get_provinces():
		if not province.has_owner_country():
			continue
		
		var json_data: Dictionary = {
			"id": province.armies.new_unique_army_id(),
			"army_size": province.population.population_size,
			"owner_country_id": province.owner_country().id,
		}
		province.armies.add_army(Army.from_JSON(json_data, game_state))
		province.armies.merge_armies()
