class_name ArmiesInEachProvince
## Provides a list of all armies located in some given province.

signal army_reordered(army: Army, position_index: int)

## All provinces in the game are guaranteed to be in this dictionary.
## Also, -1 is a valid key. It gives the list of
## all armies that are not in any province.
var dictionary: Dictionary[int, ArmiesInProvince] = {
	-1: ArmiesInProvince.new()
}


func _init(provinces: Provinces, armies: Armies) -> void:
	for province in provinces.list():
		_add_province(province)
	provinces.added.connect(_add_province)
	provinces.removed.connect(_remove_province.bind(armies))

	for army in armies.list():
		_add_army(army)
	armies.added.connect(_add_army)
	armies.removed.connect(_remove_army)


## Moves given army to given position in the list.
func move_army(army: Army, new_index: int) -> void:
	var armies_in_province: ArmiesInProvince = dictionary[army.province_id()]

	var old_index: int = armies_in_province.mapped_list[army]
	if old_index == new_index:
		return

	armies_in_province.ordered_list.erase(army)
	armies_in_province.ordered_list.insert(new_index, army)

	# Update the values in the mapped list
	for i: int in range(
			mini(old_index, new_index), maxi(old_index, new_index) + 1
	):
		armies_in_province.mapped_list[armies_in_province.ordered_list[i]] = i

	army_reordered.emit(army, new_index)


func _add_province(province: Province) -> void:
	dictionary[province.id] = ArmiesInProvince.new()


func _remove_province(province: Province, armies: Armies) -> void:
	# Remove all of the province's armies from the game
	for i in dictionary[province.id].ordered_list.size():
		armies.remove(dictionary[province.id].ordered_list[-1])

	dictionary.erase(province.id)


func _add_army(army: Army) -> void:
	_add_army_to_list(army)
	army.province_changed.connect(_add_army_to_list)


func _remove_army(army: Army) -> void:
	army.province_changed.disconnect(_add_army_to_list)
	var armies_in_province: ArmiesInProvince = dictionary[army.province_id()]
	army.province_changed.disconnect(armies_in_province.remove)
	armies_in_province.remove(army)


func _add_army_to_list(army: Army) -> void:
	var armies_in_province: ArmiesInProvince = dictionary[army.province_id()]
	armies_in_province.mapped_list[army] = (
			dictionary[army.province_id()].ordered_list.size()
	)
	armies_in_province.ordered_list.append(army)
	army.province_changed.connect(
			armies_in_province.remove, ConnectFlags.CONNECT_ONE_SHOT
	)


class ArmiesInProvince:
	## Defines the order in which armies are positioned in a province.

	## The list, as a dictionary.
	## The value is the army's position index.
	## If you edit this list, you must also edit the other list.
	var mapped_list: Dictionary[Army, int] = {}

	## The list, as an ordered array.
	## If you edit this list, you must also edit the other list.
	var ordered_list: Array[Army] = []

	func remove(army: Army) -> void:
		mapped_list.erase(army)
		ordered_list.erase(army)
