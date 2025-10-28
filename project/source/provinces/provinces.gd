class_name Provinces
## An encapsulated list of [Province]s. Provides useful functions and signals.

signal added(province: Province)
signal removed(province: Province)
signal province_owner_changed(province: Province)
signal building_added(building: Building)

## Maps a province id to a province.
var _list: Dictionary[int, Province] = {}

var _unique_id_system := UniqueIdSystem.new()


## If given province's id is invalid (i.e. a negative number),
## automatically gives it a new unique id.
##
## No effect if given province's id is already in use,
## or if given province is already in the list.
func add(province: Province) -> void:
	if _list.has(province.id):
		print_debug("Province is already in the list.")
		return
	if not _unique_id_system.is_id_valid(province.id):
		province.id = _unique_id_system.new_unique_id()
	elif not _unique_id_system.is_id_available(province.id):
		print_debug(
				"Province id is already in use. (id: " + str(province.id) + ")"
		)
		return
	else:
		_unique_id_system.claim_id(province.id)

	_list[province.id] = province
	province.owner_changed.connect(province_owner_changed.emit)
	province.buildings.added.connect(building_added.emit)
	added.emit(province)


func remove(province_id: int) -> void:
	if not _list.has(province_id):
		return
	var province: Province = _list[province_id]

	province.owner_changed.disconnect(province_owner_changed.emit)
	province.buildings.added.disconnect(building_added.emit)
	_list.erase(province_id)

	# Remove any link to this province
	for list_province_id in _list:
		_list[list_province_id].linked_province_ids().erase(province_id)

	removed.emit(province)


## Removes all provinces in this list.
## Also resets the id system so that all ids become valid again.
func clear() -> void:
	for province_id in _list:
		remove(province_id)
	_unique_id_system = UniqueIdSystem.new()


## Returns a new copy of the list.
func list() -> Array[Province]:
	return _list.values()


## Returns a list of every province that's linked to given province.
## Returns an empty list if there is no province with given id.
func links_of(province_id: int) -> Array[Province]:
	var output: Array[Province] = []
	if not _list.has(province_id):
		return output
	for linked_province_id in _list[province_id].linked_province_ids():
		if _list.has(linked_province_id):
			output.append(_list[linked_province_id])
	return output


## Returns the list of all provinces representing given [Country]'s frontline.
## Provinces in the list are not necessarily under control of given country.
func provinces_on_frontline(country: Country) -> Array[Province]:
	var output: Array[Province] = []
	for province_id in _list:
		if _list[province_id].is_frontline(country, self):
			output.append(_list[province_id])
	return output


## Returns null if no province has the given id.
func province_from_id(id: int) -> Province:
	return _list[id] if _list.has(id) else null
