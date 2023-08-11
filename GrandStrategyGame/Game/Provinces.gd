class_name Provinces
extends Node2D


var selected_province: Province = null


func select_province(province: Province):
	if selected_province == province:
		return
	if a_province_is_selected():
		selected_province.deselect()
	selected_province = province
	selected_province.select()


func unselect_province():
	if a_province_is_selected():
		selected_province.deselect()
	selected_province = null


func a_province_is_selected() -> bool:
	return selected_province != null


func get_provinces() -> Array[Province]:
	var output: Array[Province] = []
	var children: Array[Node] = get_children()
	for child in children:
		output.append(child as Province)
	return output


func province_with_key(key: String) -> Province:
	var provinces: Array[Province] = get_provinces()
	for province in provinces:
		if province.key() == key:
			return province
	return null
