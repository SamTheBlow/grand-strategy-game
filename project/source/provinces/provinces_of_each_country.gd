class_name ProvincesOfEachCountry
## Provides a list of all provinces controlled by some given country.
##
## See also: [ProvincesOfCountry]

## All countries in the game are guaranteed to be in this dictionary.
## Also, null is a valid key. It gives the list of
## all provinces that don't have an owner country.
var _map: Dictionary[Country, ProvincesOfCountry] = {
	null: ProvincesOfCountry.new()
}


func _init(countries: Countries, provinces: Provinces) -> void:
	for country in countries.list():
		_on_country_added(country)
	countries.country_added.connect(_on_country_added)

	for province in provinces.list():
		_on_province_added(province)
	provinces.added.connect(_on_province_added)
	provinces.removed.connect(_on_province_removed)


## If input is null, returns the list of provinces with no owner.
func of_country(country: Country) -> ProvincesOfCountry:
	return _map[country]


func _on_country_added(country: Country) -> void:
	_map[country] = ProvincesOfCountry.new()


func _on_province_added(province: Province) -> void:
	if province == null:
		push_error("Province is null.")
		return

	_on_province_owner_changed(province)
	province.owner_changed.connect(_on_province_owner_changed)


func _on_province_removed(province: Province) -> void:
	if not _map.has(province.owner_country):
		push_error("Country is not on the list.")
		return

	_map[province.owner_country].remove(province)


func _on_province_owner_changed(province: Province) -> void:
	if not _map.has(province.owner_country):
		push_error("Country is not on the list.")
		return

	_map[province.owner_country].add(province)
