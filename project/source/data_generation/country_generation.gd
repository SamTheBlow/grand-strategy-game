class_name CountryGeneration
## Populates given JSON data with new countries.


func apply(raw_data: Variant, number_of_countries: int) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	var countries_array: Array = []
	for i in number_of_countries:
		var new_country := Country.new()
		new_country.id = i
		new_country.country_name = "Country " + str(i + 1)
		new_country.color = Color(randf(), randf(), randf(), 1.0)
		countries_array.append(new_country.to_raw_dict())

	raw_dict.merge({ GameFromRaw.COUNTRIES_KEY: countries_array }, true)
