class_name Countries
## Represents a list of [Country].
## Provides utility function to find a country by its id.


signal country_added(country: Country)

var _list: Array[Country] = []


func add(new_country: Country) -> void:
	_list.append(new_country)
	country_added.emit(new_country)


## Returns null if there is no country with the given id.
## If the given id is negative,
## returns a new empty country without pushing any error.
func country_from_id(id: int) -> Country:
	if id < 0:
		return Country.new()
	
	for country in _list:
		if country.id == id:
			return country
	push_error("Failed to find country with id: " + str(id))
	return null


## Returns a new copy of this list.
func list() -> Array[Country]:
	return _list.duplicate()


## Returns the number of countries in this list.
func size() -> int:
	return _list.size()


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
