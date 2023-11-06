class_name RuleNewProvinceOwnership
extends Rule


func _on_start_of_turn(game_state: GameState) -> void:
	for province in game_state.world.provinces.get_provinces():
		province.set_owner_country(new_owner_of(province))


func new_owner_of(province: Province) -> Country:
	var armies_node: Armies = province.armies
	var armies: Array[Army] = armies_node.armies
	var new_owner: Country = province.owner_country()
	for army in armies:
		if army.owner_country() == province.owner_country():
			return province.owner_country()
		new_owner = army.owner_country()
	return new_owner
