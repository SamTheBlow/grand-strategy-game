class_name Countries


var countries: Array[Country] = []


func country_from_id(id: int) -> Country:
	for country in countries:
		if country.id == id:
			return country
	return Country.new()
