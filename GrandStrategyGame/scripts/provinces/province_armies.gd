class_name ProvinceArmies
extends Node2D


var position_army_host: Vector2


func remove_army(army: Army) -> void:
	army.destroyed.disconnect(remove_army)
	army.game.world.armies.armies.erase(army)
	remove_child(army)


func add_army(army: Army) -> void:
	army.destroyed.connect(remove_army)
	army.game.world.armies.armies.append(army)
	add_child(army)


func merge_armies() -> void:
	var armies: Array[Army] = (get_parent() as Province).game.world.armies.armies_in_province(get_parent() as Province)
	var number_of_armies: int = armies.size()
	for i in number_of_armies:
		for j in range(i + 1, number_of_armies):
			if armies[i].owner_country().id == armies[j].owner_country().id:
				armies[j].army_size.add(armies[i].army_size.current_size())
				remove_army(armies[i])
				break


func army_from_id(id: int) -> Army:
	var armies: Array[Army] = (get_parent() as Province).game.world.armies.armies_in_province(get_parent() as Province)
	for army in armies:
		if army.id == id:
			return army
	return null


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
