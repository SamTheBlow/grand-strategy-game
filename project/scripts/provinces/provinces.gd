class_name Provinces
extends Node2D
## An encapsulated list of [Province] objects.
## Provides useful functions.
## Also responsible for the user's selected province.
##
## Note that you are currently not meant to remove provinces from this list.
# TODO have a convenient _list member just like in all the other list classes


## What province is currently being selected.
## Selecting a province allows the user to obtain information
## and or perform [Action]s on that province.
var selected_province: Province


func add_province(province: Province) -> void:
	add_child(province)


func select_province(province: Province, can_target_links: bool) -> void:
	if selected_province == province:
		return
	if selected_province:
		selected_province.deselect()
	selected_province = province
	selected_province.select(can_target_links)


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
		if province.owner_country and province.owner_country == country:
			output.append(province)
	return output


func provinces_on_frontline(country: Country) -> Array[Province]:
	var output: Array[Province] = []
	var children: Array[Node] = get_children()
	for child in children:
		var province := child as Province
		if (
				province.owner_country
				and province.owner_country == country
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
