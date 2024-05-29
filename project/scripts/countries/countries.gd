class_name Countries
## Represents a list of [Country].
## Provides utility function to find a country by its id.


var countries: Array[Country] = []


## Note that if there is no country with given id,
## this returns a new instance of [Country].
func country_from_id(id: int) -> Country:
	for country in countries:
		if country.id == id:
			return country
	return Country.new()
