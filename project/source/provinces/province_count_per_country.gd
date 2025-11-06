class_name ProvinceCountPerCountry


## Returns the number of provinces controlled by each country.
##
## NOTICE: The resulting array does not necessarily
## contain all of a game's countries.
static func result(province_list: Array[Province]) -> Dictionary[Country, int]:
	var output: Dictionary[Country, int] = {}

	for province in province_list:
		if province.owner_country == null:
			continue
		output.get_or_add(province.owner_country, 0)
		output[province.owner_country] += 1

	return output
