class_name ProvincesOfEachCountry
## Provides a list of all provinces controlled by some given country.

## All countries in the game are guaranteed to be in this dictionary.
## Also, null is a valid key. It gives the list of
## all provinces that don't have an owner country.
## Do not manipulate this dictionary directly!
var dictionary: Dictionary[Country, ProvincesOfCountry] = {
	null: ProvincesOfCountry.new()
}


func _init(countries: Countries, provinces: Provinces) -> void:
	for country in countries.list:
		_add_country(country)
	countries.added.connect(_add_country)
	countries.removed.connect(_remove_country)

	for province in provinces.list:
		_add_province(province)
	provinces.added.connect(_add_province)
	provinces.removed.connect(_remove_province)


func _add_country(country: Country) -> void:
	if dictionary.has(country):
		push_error("Country is already in the list.")
		return

	dictionary[country] = ProvincesOfCountry.new()


func _remove_country(country: Country) -> void:
	if not dictionary.has(country):
		push_error("Country is not in the list.")
		return

	# Mark all of the country's provinces as unclaimed
	for province: Province in dictionary[country].list.duplicate():
		province.owner_country = null

	dictionary.erase(country)


func _add_province(province: Province) -> void:
	_add_province_to_list(province)
	province.owner_changed.connect(_add_province_to_list)


func _remove_province(province: Province) -> void:
	province.owner_changed.disconnect(_add_province_to_list)
	var provinces_of_country: ProvincesOfCountry = (
			dictionary[province.owner_country]
	)
	province.owner_changed.disconnect(provinces_of_country.erase)
	provinces_of_country.erase(province)


func _add_province_to_list(province: Province) -> void:
	var provinces_of_country: ProvincesOfCountry = (
			dictionary[province.owner_country]
	)
	provinces_of_country.list[province] = true
	province.owner_changed.connect(
			provinces_of_country.erase, ConnectFlags.CONNECT_ONE_SHOT
	)


class ProvincesOfCountry:
	## It's a dictionary for performance reasons. The bool value is irrelevant.
	var list: Dictionary[Province, bool] = {}

	# This is so that disconnecting the signal works
	func erase(province: Province) -> void:
		list.erase(province)
