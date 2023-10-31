class_name Armies
extends Node2D


var position_army_host: Vector2

var _armies: Array[Army]


func remove_army(army: Army) -> void:
	army.disconnect("destroyed", Callable(self, "remove_army"))
	_armies.erase(army)
	remove_child(army)


func add_army(army: Army) -> void:
	army.stop_animations()
	army.position = position_army_host - global_position
	if army.get_parent():
		(army.get_parent() as Armies).remove_army(army)
	army.name = army.key()
	
	army.connect("destroyed", Callable(self, "remove_army"))
	_armies.append(army)
	add_child(army)


func merge_armies() -> void:
	# We make a copy because we will be removing
	# elements from the original array
	var copy := _armies.duplicate() as Array[Army]
	var number_of_armies: int = _armies.size()
	for i in number_of_armies:
		for j in range(i + 1, number_of_armies):
			if copy[i].owner_country == copy[j].owner_country:
				copy[j]._army_size.add(copy[i].current_size())
				remove_army(copy[i])
				break


func army_with_key(key: String) -> Army:
	for army in _armies:
		if army.key() == key:
			return army
	return null


func get_armies_of(country: Country) -> Array[Army]:
	var result: Array[Army] = []
	for army in _armies:
		if army.owner_country == country:
			result.append(army)
	return result


func get_active_armies_of(country: Country) -> Array[Army]:
	var result: Array[Army] = []
	for army in _armies:
		if army.owner_country == country and army.is_active:
			result.append(army)
	return result


func country_has_active_army(country: Country) -> bool:
	for army in _armies:
		if army.owner_country == country and army.is_active:
			return true
	return false


func army_can_be_moved_to(army: Army, destination: Province) -> bool:
	# The army can be moved if...
	
	# - It is indeed in this province.
	var army_is_here: bool = army.get_parent() == self
	
	# - This province is linked to the destination province.
	var this_province := get_parent() as Province
	var is_neighbour: bool = this_province.is_linked_to(destination)
	
	return army_is_here and is_neighbour
