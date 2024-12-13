class_name ArmiesInEachProvince
## Provides a dictionary where each [Province]
## is assigned a list of all armies in that province ([ArmiesInProvince]).

## Dictionary[Province, ArmiesInProvince]
## All provinces in the game are guaranteed to be in this dictionary,
## so no need to check if the dictionary has some province.
## Also, null is a valid key. It will give you the list of
## all armies that are not in any province.
## Do not manipulate this dictionary directly!
var dictionary: Dictionary = {null: ArmiesInProvince.new()}


func _init(provinces: Provinces, armies: Armies) -> void:
	for province in provinces.list():
		_on_province_added(province)

	provinces.added.connect(_on_province_added)

	for army in armies.list():
		_on_army_added(army)

	armies.army_added.connect(_on_army_added)
	armies.army_removed.connect(_on_army_removed)


func _on_province_added(province: Province) -> void:
	dictionary[province] = ArmiesInProvince.new()


func _on_army_added(army: Army) -> void:
	_on_army_province_changed(army)
	army.province_changed.connect(_on_army_province_changed)


func _on_army_removed(army: Army) -> void:
	army.province_changed.disconnect(_on_army_province_changed)
	dictionary[army.province()].remove(army)


## Adds the army to the new province's list.
## As for removing the army from the previous province's list,
## the previous province's list does this by itself.
func _on_army_province_changed(army: Army) -> void:
	dictionary[army.province()].add(army)
