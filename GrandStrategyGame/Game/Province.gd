extends Node2D
class_name Province

var links:Array
var owner_country:Country = null : set = set_owner_country

func set_owner_country(country:Country):
	if country == owner_country:
		return
	owner_country = country
	if country == null:
		$Shape.color = Color.WHITE
	else:
		$Shape.color = country.color

func get_shape() -> PackedVector2Array:
	return $Shape.polygon

func set_shape(polygon:PackedVector2Array):
	$Shape.polygon = polygon

func select():
	$Shape.draw_status = 1

func deselect():
	if $Shape.draw_status == 1:
		for neighbour in links:
			neighbour.deselect()
	$Shape.draw_status = 0

func show_neighbours(display_type):
	for neighbour in links:
		neighbour.show_as_neighbour(display_type)

func show_as_neighbour(display_type):
	$Shape.draw_status = display_type

func is_linked_to(province:Province):
	return links.has(province)

func add_component(component:ProvinceComponent):
	add_child(component)
