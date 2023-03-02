extends Rule
class_name RuleNewProvinceOwnership

func _on_start_of_turn(provinces, _current_turn):
	for province in provinces:
		province.owner_country = new_owner_of(province)

func new_owner_of(province:Province) -> Country:
	var armies = province.get_node("Armies").get_alive_armies()
	var new_owner = province.owner_country
	for army in armies:
		if army.owner_country == province.owner_country:
			return province.owner_country
		new_owner = army.owner_country
	return new_owner
