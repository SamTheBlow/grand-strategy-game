class_name ArmiesOfEachCountry
## Provides a dictionary where each [Country]
## is assigned a list of all armies controlled by that country.

## Dictionary[Country, ArmiesOfCountry]
## All countries in the game are guaranteed to be in this dictionary,
## so no need to check if the dictionary has some country.
## Also, null is a valid key. It will give you the list of
## all armies that don't have an owner country.
## Do not manipulate this dictionary directly!
var dictionary: Dictionary = {null: ArmiesOfCountry.new()}


func _init(countries: Countries, armies: Armies) -> void:
	for country in countries.list():
		_on_country_added(country)
	countries.country_added.connect(_on_country_added)

	for army in armies.list():
		_on_army_added(army)
	armies.army_added.connect(_on_army_added)
	armies.army_removed.connect(_on_army_removed)


func _on_country_added(country: Country) -> void:
	dictionary[country] = ArmiesOfCountry.new()


func _on_army_added(army: Army) -> void:
	dictionary[army.owner_country].add(army)
	army.allegiance_changed.connect(_on_army_allegiance_changed)


func _on_army_removed(army: Army) -> void:
	dictionary[army.owner_country].remove(army)


func _on_army_allegiance_changed(army: Army) -> void:
	dictionary[army.owner_country].add(army)
