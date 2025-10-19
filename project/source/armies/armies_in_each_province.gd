class_name ArmiesInEachProvince
## Provides a list of all armies located in some given province.
##
## See also: [ArmiesInProvince]

## All provinces in the game are guaranteed to be in this dictionary.
## Also, -1 is a valid key. It gives the list of
## all armies that are not in any province.
var _map: Dictionary[int, ArmiesInProvince] = { -1: ArmiesInProvince.new() }


func _init(provinces: Provinces, armies: Armies) -> void:
	for province in provinces.list():
		_on_province_added(province)

	provinces.added.connect(_on_province_added)
	provinces.removed.connect(_on_province_removed)

	for army in armies.list():
		_on_army_added(army)

	armies.army_added.connect(_on_army_added)
	armies.army_removed.connect(_on_army_removed)


func in_province_id(province_id: int) -> ArmiesInProvince:
	if not _map.has(province_id):
		push_error("Province is not on the list.")
		return _map[-1]
	return _map[province_id]


## If given province is null,
## returns a list of all armies that are not in any province.
func in_province(province: Province) -> ArmiesInProvince:
	if province == null:
		return _map[-1]
	return in_province_id(province.id)


func values() -> Array[ArmiesInProvince]:
	return _map.values()


func _on_province_added(province: Province) -> void:
	_map[province.id] = ArmiesInProvince.new()


func _on_province_removed(province: Province) -> void:
	_map.erase(province.id)


func _on_army_added(army: Army) -> void:
	_on_army_province_changed(army)
	army.province_changed.connect(_on_army_province_changed)


func _on_army_removed(army: Army) -> void:
	army.province_changed.disconnect(_on_army_province_changed)
	if not _map.has(army.province_id()):
		push_warning("Province is not on the list.")
		return
	_map[army.province_id()].remove(army)


## Adds the army to the new province's list.
## As for removing the army from the previous province's list,
## the previous province's list does this by itself.
func _on_army_province_changed(army: Army) -> void:
	if not _map.has(army.province_id()):
		push_warning("Province is not on the list.")
		return
	_map[army.province_id()].add(army)
