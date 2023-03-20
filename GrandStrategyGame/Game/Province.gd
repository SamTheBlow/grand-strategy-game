class_name Province
extends Node2D


signal selected

var links: Array[Province] = []
var owner_country: Country = null : set = set_owner_country


func _on_shape_clicked():
	emit_signal("selected", self)


func province_shape() -> ProvinceShape:
	return $Shape as ProvinceShape


func set_owner_country(country: Country):
	if country == owner_country:
		return
	owner_country = country
	
	var shape_node: ProvinceShape = province_shape()
	if country:
		shape_node.color = country.color
	else:
		shape_node.color = Color.WHITE


func get_shape() -> PackedVector2Array:
	return province_shape().polygon


func set_shape(polygon: PackedVector2Array):
	province_shape().polygon = polygon


func select():
	province_shape().draw_status = 1


func deselect():
	var shape_node: ProvinceShape = province_shape()
	if shape_node.draw_status == 1:
		for link in links:
			link.deselect()
	shape_node.draw_status = 0


func show_neighbours(display_type: int):
	for link in links:
		link.show_as_neighbour(display_type)


func show_as_neighbour(display_type: int):
	province_shape().draw_status = display_type


func is_linked_to(province: Province) -> bool:
	return links.has(province)


func add_component(component: ProvinceComponent):
	add_child(component)
