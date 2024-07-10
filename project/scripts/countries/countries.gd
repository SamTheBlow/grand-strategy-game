class_name Countries
## Represents a list of [Country].
## Provides utility function to find a country by its id.


var countries: Array[Country] = []


## Returns null if there is no country with the given id.
## If the given id is negative,
## returns a new empty country without pushing any error.
func country_from_id(id: int) -> Country:
	if id < 0:
		return Country.new()
	
	for country in countries:
		if country.id == id:
			return country
	push_error("Failed to find country with id: " + str(id))
	return null
