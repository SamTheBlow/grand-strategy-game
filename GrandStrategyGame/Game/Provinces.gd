extends Node2D

var selected_province:Province = null

func select_province(province:Province):
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
	var result:Array[Province] = []
	var children:Array[Node] = get_children()
	for child in children:
		if child is Province:
			result.append(child)
	return result
