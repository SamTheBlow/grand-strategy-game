class_name Provinces
## An encapsulated list of [Province] objects.
## Provides useful functions and signals.
##
## Note that you are currently not meant to remove provinces from this list.

signal added(province: Province)
# TODO implement (work in progress)
@warning_ignore("unused_signal")
signal removed(province: Province)
signal province_owner_changed(province: Province)

var _list: Array[Province] = []
var _unique_id_system := UniqueIdSystem.new()


## If given province's id is invalid (i.e. a negative number),
## automatically gives it a new unique id.
##
## No effect if given province's id is already in use,
## or if given province is already in the list.
func add(province: Province) -> void:
	if _list.has(province):
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

	_list.append(province)
	province.owner_changed.connect(province_owner_changed.emit)
	added.emit(province)


## Returns a new copy of the list.
func list() -> Array[Province]:
	return _list.duplicate()


## Returns the list of all provinces representing given [Country]'s frontline.
## Provinces in the list are not necessarily under control of given country.
func provinces_on_frontline(country: Country) -> Array[Province]:
	var output: Array[Province] = []
	for province in _list:
		if province.is_frontline(country, self):
			output.append(province)
	return output


## Returns null if no province has the given id.
func province_from_id(id: int) -> Province:
	for province in _list:
		if province.id == id:
			return province
	return null
