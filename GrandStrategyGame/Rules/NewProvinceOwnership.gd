class_name RuleNewProvinceOwnership
extends Rule


func _on_start_of_turn(game_state: GameState):
	var provinces_node: Provinces = (
		get_parent().get_parent().get_node("Provinces") as Provinces
	)
	var province_nodes: Array[Province] = provinces_node.get_provinces()
	
	for province in province_nodes:
		var new_owner: Country = new_owner_of(province)
		
		# Internal change
		var province_owner: GameStateString = (
			game_state.province_owner(province.key())
		)
		if new_owner == null:
			province_owner.data = "-1"
		else:
			province_owner.data = String(new_owner.key())
		
		# Visual change
		province.owner_country = new_owner


func new_owner_of(province: Province) -> Country:
	var armies_node := province.get_node("Armies") as Armies
	var armies: Array[Army] = armies_node.get_alive_armies()
	var new_owner: Country = province.owner_country
	for army in armies:
		if army.owner_country == province.owner_country:
			return province.owner_country
		new_owner = army.owner_country
	return new_owner
