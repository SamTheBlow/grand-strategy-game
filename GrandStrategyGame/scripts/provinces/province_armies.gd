class_name ProvinceArmies
extends Node2D


var position_army_host: Vector2

var armies: Array[Army]


func remove_army(army: Army) -> void:
	army.destroyed.disconnect(remove_army)
	armies.erase(army)
	remove_child(army)


func add_army(army: Army) -> void:
	if not army.animation_is_playing:
		army.position = position_army_host - global_position
	if army.get_parent():
		(army.get_parent() as ProvinceArmies).remove_army(army)
	army.name = str(army.id)
	
	army.destroyed.connect(remove_army)
	army._province = get_parent() as Province
	armies.append(army)
	add_child(army)
	
	army.resolve_battles(armies)


func merge_armies() -> void:
	# We make a copy because we will be removing
	# elements from the original array
	var copy := armies.duplicate() as Array[Army]
	var number_of_armies: int = armies.size()
	for i in number_of_armies:
		for j in range(i + 1, number_of_armies):
			if copy[i].owner_country().id == copy[j].owner_country().id:
				copy[j].army_size.add(copy[i].army_size.current_size())
				remove_army(copy[i])
				break


func army_from_id(id: int) -> Army:
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


func get_armies_of(country: Country) -> Array[Army]:
	var result: Array[Army] = []
	for army in armies:
		if army.owner_country() == country:
			result.append(army)
	return result


func get_active_armies_of(country: Country) -> Array[Army]:
	var result: Array[Army] = []
	for army in armies:
		if army.owner_country() == country and army.is_active:
			result.append(army)
	return result


func country_has_active_army(country: Country) -> bool:
	for army in armies:
		if army.owner_country() == country and army.is_active:
			return true
	return false
