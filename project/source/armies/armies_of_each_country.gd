class_name ArmiesOfEachCountry
## Provides a dictionary where each [Country] is mapped to
## a list of all armies controlled by that country.

## All countries in the game are guaranteed to be in this dictionary,
## so no need to check if the dictionary has some country.
## Also, null is a valid key. It will give you the list of
## all armies that don't have an owner country.
## Do not manipulate this dictionary directly!
var dictionary: Dictionary[Country, ArmiesOfCountry] = {
	null: ArmiesOfCountry.new()
}


func _init(countries: Countries, armies: Armies) -> void:
	for country in countries.list():
		_add_country(country)
	countries.added.connect(_add_country)
	countries.removed.connect(_remove_country.bind(armies))

	for army in armies.list():
		_add_army(army)
	armies.added.connect(_add_army)
	armies.removed.connect(_remove_army)


func _add_country(country: Country) -> void:
	if dictionary.has(country):
		push_error("Country is already in the list.")
		return

	dictionary[country] = ArmiesOfCountry.new()


func _remove_country(country: Country, armies: Armies) -> void:
	if not dictionary.has(country):
		push_error("Country is not in the list.")
		return

	# Remove all of the country's armies from the game
	for army: Army in dictionary[country].list.duplicate():
		armies.remove(army)

	dictionary.erase(country)


func _add_army(army: Army) -> void:
	dictionary[army.owner_country].list[army] = true
	army.allegiance_changed.connect(
			dictionary[army.owner_country].erase,
			ConnectFlags.CONNECT_ONE_SHOT
			| ConnectFlags.CONNECT_APPEND_SOURCE_OBJECT
	)
	army.allegiance_changed.connect(
			_on_army_allegiance_changed,
			ConnectFlags.CONNECT_APPEND_SOURCE_OBJECT
	)


func _remove_army(army: Army) -> void:
	army.allegiance_changed.disconnect(dictionary[army.owner_country].erase)
	army.allegiance_changed.disconnect(_on_army_allegiance_changed)
	dictionary[army.owner_country].list.erase(army)


func _on_army_allegiance_changed(army: Army) -> void:
	dictionary[army.owner_country].list[army] = true
	army.allegiance_changed.connect(
			dictionary[army.owner_country].erase,
			ConnectFlags.CONNECT_ONE_SHOT
			| ConnectFlags.CONNECT_APPEND_SOURCE_OBJECT
	)


class ArmiesOfCountry:
	## It's a dictionary for performance reasons. The bool value is irrelevant.
	var list: Dictionary[Army, bool] = {}
	# This is so that disconnecting the signal works
	func erase(value: Army) -> void:
		list.erase(value)
