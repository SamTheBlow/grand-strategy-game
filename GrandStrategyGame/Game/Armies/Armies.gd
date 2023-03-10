extends ProvinceComponent
class_name Armies

var position_army_host:Vector2

func add_army(army:Army):
	army.stop_animations()
	army.position = position_army_host - global_position
	if army.get_parent():
		army.get_parent().remove_child(army)
	add_child(army)

# Avoids interacting with armies that are queued for deletion.
# This is somewhat annoying.
func get_alive_armies() -> Array:
	var result = []
	var armies = get_children()
	for army in armies:
		if army.is_queued_for_deletion() == false:
			result.append(army)
	return result

func merge_armies():
	var armies = get_alive_armies()
	var number_of_armies = armies.size()
	for i in number_of_armies:
		for j in range(i + 1, number_of_armies):
			if armies[i].owner_country == armies[j].owner_country:
				armies[i].queue_free()
				armies[j].troop_count += armies[i].troop_count

func get_armies_of(country:Country) -> Array:
	var result = []
	var armies = get_alive_armies()
	for army in armies:
		if army.owner_country == country:
			result.append(army)
	return result

func get_active_armies_of(country:Country) -> Array:
	var result = []
	var armies = get_alive_armies()
	for army in armies:
		if army.owner_country == country && army.is_active:
			result.append(army)
	return result

func country_has_active_army(country:Country) -> bool:
	var armies = get_alive_armies()
	for army in armies:
		if army.owner_country == country && army.is_active:
			return true
	return false

func army_can_be_moved_to(army:Army, destination:Province) -> bool:
	# The army can be moved if...
	# - It is indeed in this province.
	var army_is_here = army.get_parent() == self
	# - This province is linked to the destination province.
	var is_neighbour = get_parent().is_linked_to(destination)
	return army_is_here && is_neighbour

func move_army_to(army:Army, destination:Province):
	if army_can_be_moved_to(army, destination):
		destination.get_node("Armies").add_troops(army)
