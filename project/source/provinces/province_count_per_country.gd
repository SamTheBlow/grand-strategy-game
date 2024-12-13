class_name ProvinceCountPerCountry
## Tells how many [Province]s each [Country] controls.

## These two arrays always have the same size.
## The n-th element in "number_of_provinces" is the number of provinces
## controlled by the n-th country in "countries".
var countries: Array[Country] = []
var number_of_provinces: Array[int] = []


## Calculates the number of provinces controlled by each country.
## Make sure to call this function whenever you want up-to-date information.
func calculate(province_list: Array[Province]) -> void:
	countries = []
	number_of_provinces = []

	for province in province_list:
		var country: Country = province.owner_country

		if country == null:
			continue

		var index: int = countries.find(country)

		if index == -1:
			# The country isn't on our list. Add it
			countries.append(country)
			number_of_provinces.append(1)
		else:
			# It is on our list. Increase its number of owned provinces
			number_of_provinces[index] += 1
