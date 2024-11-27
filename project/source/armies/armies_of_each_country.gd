class_name ArmiesOfEachCountry


## Dictionary[Country, ArmiesOfCountry]
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
