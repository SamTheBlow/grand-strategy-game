class_name ArmiesInEachProvince
## Provides a list of all armies located in some given province.
##
## See also: [ArmiesInProvince]

var _armies: Armies

## All provinces in the game are guaranteed to be in this dictionary.
## Also, -1 is a valid key. It gives the list of
## all armies that are not in any province.
var _map: Dictionary[int, ArmiesInProvince] = { -1: ArmiesInProvince.new() }


func _init(provinces: Provinces, armies: Armies) -> void:
	_armies = armies

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
	if not _map.has(province.id):
		push_error("Province is not in the list.")
		return

	# Immediately remove the province from the list.
	var armies_in_province: ArmiesInProvince = _map[province.id]
	_map.erase(province.id)

	# Remove all armies that were on that province, one by one.
	for i in armies_in_province.list.size():
		var army_to_remove: Army = armies_in_province.list[-1]
		armies_in_province.remove(army_to_remove)
		_armies.remove_army(army_to_remove)


func _on_army_added(army: Army) -> void:
	_on_army_province_changed(army)
	army.province_changed.connect(_on_army_province_changed)


func _on_army_removed(army: Army) -> void:
	army.province_changed.disconnect(_on_army_province_changed)
	if not _map.has(army.province_id()):
		return
	_map[army.province_id()].remove(army)


## Adds the army to the new province's list.
## As for removing the army from the previous province's list,
## the previous province's list does this by itself.
## If the army's province doesn't exist, removes the army.
func _on_army_province_changed(army: Army) -> void:
	if not _map.has(army.province_id()):
		_armies.remove_army(army)
		return
	_map[army.province_id()].add(army)
