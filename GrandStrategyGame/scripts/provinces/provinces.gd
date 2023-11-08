class_name Provinces
extends Node2D


var selected_province: Province


func add_province(province: Province) -> void:
	add_child(province)


func select_province(province: Province) -> void:
	if selected_province == province:
		return
	if selected_province:
		selected_province.deselect()
	selected_province = province
	selected_province.select()


func deselect_province() -> void:
	if selected_province:
		selected_province.deselect()
	selected_province = null


func get_provinces() -> Array[Province]:
	var output: Array[Province] = []
	var children: Array[Node] = get_children()
	for child in children:
		output.append(child as Province)
	return output


func province_from_id(id: int) -> Province:
	var provinces: Array[Province] = get_provinces()
	for province in provinces:
		if province.id == id:
			return province
	return null


func connect_to_provinces(callable: Callable) -> void:
	var provinces: Array[Province] = get_provinces()
	for province in provinces:
		province.connect("selected", callable)


func as_json() -> Array:
	var array: Array = []
	for province in get_provinces():
		array.append(province.as_json())
	return array
