extends Node

var selected_province:Province = null

func select_province(province):
	if selected_province == province:
		return
	if a_province_is_selected():
		selected_province.unselect()
	selected_province = province
	selected_province.select()

func unselect_province():
	if a_province_is_selected():
		selected_province.unselect()
	selected_province = null

func a_province_is_selected() -> bool:
	return selected_province != null
