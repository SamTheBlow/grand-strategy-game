class_name ArmiesOfEachCountry
## Provides a dictionary where each [Country] is assigned
## a list of all armies controlled by that country ([ArmiesOfCountry]).

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
		_on_country_added(country)
	countries.added.connect(_on_country_added)
	countries.removed.connect(_on_country_removed.bind(armies))

	for army in armies.list():
		_on_army_added(army)
	armies.army_added.connect(_on_army_added)
	armies.army_removed.connect(_on_army_removed)


func _on_country_added(country: Country) -> void:
	if dictionary.has(country):
		push_error("Country is already in the list.")
		return

	dictionary[country] = ArmiesOfCountry.new()


func _on_country_removed(country: Country, armies: Armies) -> void:
	if not dictionary.has(country):
		push_error("Country is not in the list.")
		return

	# Remove all of the country's armies from the game
	for army: Army in dictionary[country].list.duplicate():
		armies.remove_army(army)

	dictionary.erase(country)


func _on_army_added(army: Army) -> void:
	dictionary[army.owner_country].add(army)
	army.allegiance_changed.connect(_on_army_allegiance_changed)


func _on_army_removed(army: Army) -> void:
	dictionary[army.owner_country].remove(army)


func _on_army_allegiance_changed(army: Army) -> void:
	dictionary[army.owner_country].add(army)
