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


func _on_province_owner_changed(province: Province) -> void:
	province_owner_changed.emit(province)
