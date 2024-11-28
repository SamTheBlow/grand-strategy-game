class_name ProvincesOfEachCountry
## Provides a dictionary where each [Country]
## is assigned a list of all provinces controlled by that country.


## Dictionary[Country, ProvincesOfCountry]
## All countries in the game are guaranteed to be in this dictionary,
## so no need to check if the dictionary has some country.
## Also, null is a valid key. It will give you the list of
## all provinces that don't have an owner country.
## Do not manipulate this dictionary directly!
var dictionary: Dictionary = {null: ProvincesOfCountry.new()}


func _init(countries: Countries, provinces: Provinces) -> void:
	for country in countries.list():
		_on_country_added(country)
	countries.country_added.connect(_on_country_added)

	for province in provinces.list():
		_on_province_added(province)
	provinces.added.connect(_on_province_added)


func _on_country_added(country: Country) -> void:
	dictionary[country] = ProvincesOfCountry.new()


func _on_province_added(province: Province) -> void:
	dictionary[province.owner_country].add(province)
	province.owner_changed.connect(_on_province_owner_changed)


func _on_province_owner_changed(province: Province) -> void:
	dictionary[province.owner_country].add(province)
