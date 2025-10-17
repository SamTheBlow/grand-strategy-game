class_name Countries
## An encapsulated list of [Country] objects.

signal country_added(country: Country)

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
	country_added.emit(country)


## Returns null if there is no country with given id.
func country_from_id(id: int) -> Country:
	for country in _list:
		if country.id == id:
			return country
	return null


## Returns a new copy of this list.
func list() -> Array[Country]:
	return _list.duplicate()


## Returns the number of countries in this list.
func size() -> int:
	return _list.size()


## Returns a new instance parsed from given raw data.
static func from_raw_data(raw_data: Variant) -> Countries:
	return CountryParsing.countries_from_raw_data(raw_data)


## Returns this instance parsed to a raw array.
func to_raw_array() -> Array:
	return CountryParsing.countries_to_raw_array(_list)
