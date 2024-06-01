class_name Provinces
extends Node2D
## An encapsulated list of [Province] objects.
## Provides useful functions.
## Also responsible for the user's selected province.
##
## Note that you are currently not meant to remove provinces from this list.


## What province is currently being selected.
## Selecting a province allows the user to obtain information
## and or perform [Action]s on that province.
var selected_province: Province

var _list: Array[Province] = []


func add_province(province: Province) -> void:
	add_child(province)
	_list.append(province)


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


## Returns a new copy of the list.
func list() -> Array[Province]:
	return _list.duplicate()


func provinces_of_country(country: Country) -> Array[Province]:
	var output: Array[Province] = []
	for province in _list:
		if province.owner_country and province.owner_country == country:
			output.append(province)
	return output


func provinces_on_frontline(country: Country) -> Array[Province]:
	var output: Array[Province] = []
	for province in _list:
		if (
				province.owner_country
				and province.owner_country == country
				and province.is_frontline()
		):
			output.append(province)
	return output


## Returns null if no province has the given id.
func province_from_id(id: int) -> Province:
	for province in _list:
		if province.id == id:
			return province
	return null
