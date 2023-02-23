extends Node2D
class_name Province

var position_army_host:Vector2
var links

var owner_country:Country = null setget set_owner_country

func is_owned_by(country:Country):
	if owner_country == null:
		return false
	return owner_country == country

func set_owner_country(country:Country):
	owner_country = country
	$Shape.color = country.color

func get_shape() -> PoolVector2Array:
	return $Shape.polygon

func set_shape(polygon:PoolVector2Array):
	$Shape.polygon = polygon

func select():
	$Shape.draw_status = 1

func unselect():
	if $Shape.draw_status == 1:
		for neighbour in links:
			neighbour.unselect()
	$Shape.draw_status = 0

func show_neighbours(display_type):
	for neighbour in links:
		neighbour.show_as_neighbour(display_type)

func show_as_neighbour(display_type):
	$Shape.draw_status = display_type

func add_troops(army:Army):
	army.stop_animations()
	army.position = position_army_host - position
	if army.get_parent():
		army.get_parent().remove_child(army)
	$Armies.add_child(army)

func merge_armies():
	var armies = get_alive_armies()
	var number_of_armies = armies.size()
	for i in number_of_armies:
		for j in range(i + 1, number_of_armies):
			if armies[i].owner_country == armies[j].owner_country:
				armies[i].queue_free()
				armies[j].troop_count += armies[i].troop_count

func is_linked_to(province:Province):
	return links.has(province)

#TODO change country to army
func move_army_to(country:Country, province:Province):
	if army_can_be_moved_to(country, province):
		var army = get_active_army(country)
		province.add_troops(army)

func army_can_be_moved_to(country:Country, province:Province):
	# Troops can be moved if...
	# - This province has an active army owned by the country.
	var has_player_owned_army = country_has_active_army(country)
	# - This province is linked to the destination province.
	var is_neighbour = is_linked_to(province)
	return has_player_owned_army && is_neighbour

func country_has_active_army(country:Country):
	var a = get_active_army(country)
	return a != null

func get_active_army(country:Country):
	var armies = get_alive_armies()
	for a in armies:
		if a.owner_country == country && a.is_active:
			return a
	return null

func get_army(country:Country):
	var armies = get_alive_armies()
	for a in armies:
		if a.owner_country == country:
			return a
	return null

func get_armies_of(country:Country) -> Array:
	var result = []
	var armies = get_alive_armies()
	for a in armies:
		if a.owner_country == country:
			result.append(a)
	return result

func new_owner() -> Country:
	var armies = get_alive_armies()
	var new_owner = null
	for a in armies:
		if a.owner_country == owner_country:
			return null
		new_owner = a.owner_country
	return new_owner

# Temporary?
func look_for_battles():
	var armies = get_alive_armies()
	var number_of_armies = armies.size()
	for i in number_of_armies:
		for j in range(i + 1, number_of_armies):
			if armies[i].owner_country != armies[j].owner_country:
				armies[i].attack(armies[j])

# Avoids interacting with armies that are queued for deletion.
# This is very annoying.
func get_alive_armies() -> Array:
	var armies = $Armies.get_children()
	var result = []
	for a in armies:
		if a.is_queued_for_deletion() == false:
			result.append(a)
	return result
