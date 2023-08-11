class_name Armies
extends ProvinceComponent


var position_army_host: Vector2


func add_army(army: Army):
	army.stop_animations()
	army.position = position_army_host - global_position
	if army.get_parent():
		army.get_parent().remove_child(army)
	add_child(army)


# Avoids interacting with armies that are queued for deletion.
# This is somewhat annoying.
func get_alive_armies() -> Array[Army]:
	var result: Array[Army] = []
	var armies: Array[Node] = get_children()
	for army in armies:
		if army.is_queued_for_deletion() == false:
			result.append(army as Army)
	return result


func merge_armies():
	var armies: Array[Army] = get_alive_armies()
	var number_of_armies: int = armies.size()
	for i in number_of_armies:
		for j in range(i + 1, number_of_armies):
			if armies[i].owner_country == armies[j].owner_country:
				armies[i].queue_free()
				armies[j].troop_count += armies[i].troop_count
				break


func army_with_key(key: String) -> Army:
	var armies: Array[Army] = get_alive_armies()
	for army in armies:
		if army.key() == key:
			return army
	return null


func get_armies_of(country: Country) -> Array[Army]:
	var result: Array[Army] = []
	var armies: Array[Army] = get_alive_armies()
	for army in armies:
		if army.owner_country == country:
			result.append(army)
	return result


func get_active_armies_of(country: Country) -> Array[Army]:
	var result: Array[Army] = []
	var armies: Array[Army] = get_alive_armies()
	for army in armies:
		if army.owner_country == country and army.is_active:
			result.append(army)
	return result


func country_has_active_army(country: Country) -> bool:
	var armies: Array[Army] = get_alive_armies()
	for army in armies:
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


func move_army_to(army: Army, destination: Province):
	if army_can_be_moved_to(army, destination):
		var armies_node := destination.get_node("Armies") as Armies
		armies_node.add_troops(army)
