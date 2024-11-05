class_name CountryGeneration
## Populates given JSON data with new countries.


func apply(raw_data: Variant, number_of_countries: int) -> void:
	if raw_data is not Dictionary:
		return
	
	var countries_array: Array = []
	for i in number_of_countries:
		var random_color := Color.WHITE
		random_color.r = randf()
		random_color.g = randf()
		random_color.b = randf()
		
		var country_dict: Dictionary = {
			GameFromRawDict.COUNTRY_ID_KEY: i,
			GameFromRawDict.COUNTRY_NAME_KEY: "Country " + str(i + 1),
			GameFromRawDict.COUNTRY_COLOR_KEY: random_color.to_html(false),
		}
		countries_array.append(country_dict)
	
	var merge_dict: Dictionary = {GameFromRawDict.COUNTRIES_KEY: countries_array}
	(raw_data as Dictionary).merge(merge_dict, true)
