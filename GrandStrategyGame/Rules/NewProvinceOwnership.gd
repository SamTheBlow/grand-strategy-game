class_name RuleNewProvinceOwnership
extends Rule


func _on_start_of_turn(provinces: Array[Province], _current_turn: int):
	for province in provinces:
		province.owner_country = new_owner_of(province)


func new_owner_of(province: Province) -> Country:
	var armies_node := province.get_node("Armies") as Armies
	var armies: Array[Army] = armies_node.get_alive_armies()
	var new_owner: Country = province.owner_country
	for army in armies:
		if army.owner_country == province.owner_country:
			return province.owner_country
		new_owner = army.owner_country
	return new_owner
