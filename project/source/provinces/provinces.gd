class_name Provinces
## An encapsulated list of [Province] objects.
## Provides useful functions and signals.
##
## Note that you are currently not meant to remove provinces from this list.


signal added(province: Province)
signal province_owner_changed(province: Province)

var _list: Array[Province] = []


func add_province(province: Province) -> void:
	_list.append(province)
	province.owner_changed.connect(_on_province_owner_changed)
	added.emit(province)


## Returns a new copy of the list.
func list() -> Array[Province]:
	return _list.duplicate()


func provinces_of_country(country: Country) -> Array[Province]:
	var output: Array[Province] = []
	for province in _list:
		if province.owner_country and province.owner_country == country:
			output.append(province)
	return output


## Returns the list of all provinces representing given [Country]'s frontline.
## Provinces in the list are not necessarily under control of given country.
func provinces_on_frontline(country: Country) -> Array[Province]:
	var output: Array[Province] = []
	for province in _list:
		if province.is_frontline(country):
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


func _on_province_owner_changed(province: Province) -> void:
	province_owner_changed.emit(province)
