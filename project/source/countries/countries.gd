class_name Countries
## A list of [Country] objects.
## Provides utility functions and signals.

signal country_added(country: Country)

var _list: Array[Country] = []
var _unique_id_system := UniqueIdSystem.new()


## Note that this overwrites the country's id.
## If you want the country to use a specific id, pass it as an argument.
##
## No effect if given id is already in use.
## Use is_id_available first to verify (see [UniqueIdSystem]).
func add(new_country: Country, specific_id: int = -1) -> void:
	var id: int = specific_id
	if not _unique_id_system.is_id_valid(specific_id):
		id = _unique_id_system.new_unique_id()
	elif not _unique_id_system.is_id_available(specific_id):
		print_debug(
				"Country id is already in use. (id: " + str(specific_id) + ")"
		)
		return
	else:
		_unique_id_system.claim_id(specific_id)

	new_country.id = id
	_list.append(new_country)
	country_added.emit(new_country)


## Returns null if there is no country with given id.
func country_from_id(id: int) -> Country:
	for country in _list:
		if country.id == id:
			return country

	return null


func id_system() -> UniqueIdSystem:
	return _unique_id_system


## Returns a new copy of this list.
func list() -> Array[Country]:
	return _list.duplicate()


## Returns the number of countries in this list.
func size() -> int:
	return _list.size()


static func from_raw_data(raw_data: Variant) -> Countries:
	return CountryParsing.countries_from_raw_data(raw_data)


func to_raw_array() -> Array:
	return CountryParsing.countries_to_raw_array(_list)


## Debug function that prints the status of all country relationships.
func print_relationships() -> void:
	for country_1 in _list:
		print("Country: ", country_1.country_name)
		for country_2 in _list:
			if country_1 == country_2:
				continue
			print(
					"	", country_2.country_name, ": ",
					country_1.relationships
					.with_country(country_2).preset().name
			)
