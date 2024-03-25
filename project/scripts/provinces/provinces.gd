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


## Creates a brand new array every time.
func get_provinces() -> Array[Province]:
	var output: Array[Province] = []
	var children: Array[Node] = get_children()
	for child in children:
		output.append(child as Province)
	return output


func provinces_of_country(country: Country) -> Array[Province]:
	var output: Array[Province] = []
	var children: Array[Node] = get_children()
	for child in children:
		var province := child as Province
		if (
				province.has_owner_country()
				and province.owner_country() == country
		):
			output.append(province)
	return output


func provinces_on_frontline(country: Country) -> Array[Province]:
	var output: Array[Province] = []
	var children: Array[Node] = get_children()
	for child in children:
		var province := child as Province
		if (
				province.has_owner_country()
				and province.owner_country() == country
				and province.is_frontline()
		):
			output.append(province)
	return output


func province_from_id(id: int) -> Province:
	var provinces: Array[Province] = get_provinces()
	for province in provinces:
		if province.id == id:
			return province
	return null
