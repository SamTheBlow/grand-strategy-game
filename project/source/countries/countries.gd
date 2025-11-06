class_name Countries
## An encapsulated list of [Country] objects.

signal added(country: Country)

## Maps to each country its unique id, for fast lookup.
var _map: Dictionary[int, Country] = {}

var _list: Array[Country] = []
var _unique_id_system := UniqueIdSystem.new()


## If given country's id is invalid (i.e. a negative number),
## automatically gives it a new unique id.
##
## No effect if given country's id is already in use,
## or if given country is already in the list.
func add(country: Country) -> void:
	if _list.has(country):
		print_debug("Country is already in the list.")
		return
	if not _unique_id_system.is_id_valid(country.id):
		country.id = _unique_id_system.new_unique_id()
	elif not _unique_id_system.is_id_available(country.id):
		print_debug(
				"Country id is already in use. (id: " + str(country.id) + ")"
		)
		return
	else:
		_unique_id_system.claim_id(country.id)

	_list.append(country)
	_map[country.id] = country
	added.emit(country)


## Returns null if there is no country with given id.
func country_from_id(id: int) -> Country:
	return _map[id] if _map.has(id) else null


## Returns a new copy of this list.
func list() -> Array[Country]:
	return _list.duplicate()


## Returns the number of countries in this list.
func size() -> int:
	return _list.size()
