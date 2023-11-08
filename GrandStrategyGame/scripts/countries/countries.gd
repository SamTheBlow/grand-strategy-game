class_name Countries
extends Node
## Don't use add_child() to add a country: use add_country() instead


# Conveniently contains all the countries in a typed array
var countries: Array[Country] = []


func add_country(country: Country) -> void:
	countries.append(country)
	add_child(country)


func country_from_id(id: int) -> Country:
	for country in countries:
		if country.id == id:
			return country
	return Country.new()


func as_json() -> Array:
	var array: Array = []
	for country in countries:
		array.append(country.as_json())
	return array
