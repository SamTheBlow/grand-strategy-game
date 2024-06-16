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


## Returns an Array telling how many [Province]s each [Country] controls.
## Each element in the Array is an Array with two elements:
## - Element 0 is a [Country].
## - Element 1 is the number of [Province]s controlled by that [Country].
func province_count_per_country() -> Array:
	var output: Array = []
	
	for province in _list:
		if not province.owner_country:
			continue
		
		# Find the country on our list
		var index: int = -1
		var output_size: int = output.size()
		for i in output_size:
			if output[i][0] == province.owner_country:
				index = i
				break
		
		# It isn't on our list. Add it
		if index == -1:
			output.append([province.owner_country, 1])
		# It is on our list. Increase its number of owned provinces
		else:
			output[index][1] += 1
	
	return output
