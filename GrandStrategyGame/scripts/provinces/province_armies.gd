class_name ProvinceArmies
extends Node2D


var position_army_host: Vector2


func new_unique_army_ids(number_of_ids: int) -> Array[int]:
	var result: Array[int] = []
	for i in number_of_ids:
		result.append(new_unique_army_id())
	return result


func new_unique_army_id() -> int:
	var armies: Array[Army] = (get_parent() as Province).game.world.armies.armies_in_province(get_parent() as Province)
	
	var new_id: int
	var id_is_unique: bool = false
	while not id_is_unique:
		new_id = randi()
		id_is_unique = true
		for army in armies:
			if army.id == new_id:
				id_is_unique = false
				break
	return new_id


func get_active_armies_of(country: Country) -> Array[Army]:
	var result: Array[Army] = []
	var armies: Array[Army] = (get_parent() as Province).game.world.armies.armies_in_province(get_parent() as Province)
	for army in armies:
		if army.owner_country() == country and army.is_active:
			result.append(army)
	return result


func country_has_active_army(country: Country) -> bool:
	var armies: Array[Army] = (get_parent() as Province).game.world.armies.armies_in_province(get_parent() as Province)
	for army in armies:
		if army.owner_country() == country and army.is_active:
			return true
	return false
