class_name Provinces
## An encapsulated list of [Province] objects.
## Provides useful functions and signals.
##
## Note that you are currently not meant to remove provinces from this list.


signal added(province: Province)
signal province_owner_changed(province: Province)

var _list: Array[Province] = []
var _unique_id_system := UniqueIdSystem.new()


## Note that this overwrites the province's id.
## If you want the province to use a specific id, pass it as an argument.
##
## An error will occur if given id is not available.
## Use is_id_available first to verify (see [UniqueIdSystem]).
func add_province(province: Province, specific_id: int = -1) -> void:
	var id: int = specific_id
	if not _unique_id_system.is_id_valid(specific_id):
		id = _unique_id_system.new_unique_id()
	elif not _unique_id_system.is_id_available(specific_id):
		push_error(
				"Specified province id is not unique."
				+ " (id: " + str(specific_id) + ")"
		)
		id = _unique_id_system.new_unique_id()
	else:
		_unique_id_system.claim_id(specific_id)

	province.id = id
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


func id_system() -> UniqueIdSystem:
	return _unique_id_system


func _on_province_owner_changed(province: Province) -> void:
	province_owner_changed.emit(province)
