class_name Armies
## An encapsulated list of [Army] objects.
## Provides utility functions for manipulating the list and
## for accessing a specific [Army] or a specific subset of the list.


signal army_added(army: Army)
signal army_removed(army: Army)

var _list: Array[Army] = []
var _unique_id_system := UniqueIdSystem.new()


## Note that this overwrites the army's id.
## If you want the army to use a specific id, pass it as an argument.
##
## An error will occur if given id is not available.
## Use is_id_available first to verify (see [UniqueIdSystem]).
func add_army(army: Army, specific_id: int = -1) -> void:
	if _list.has(army):
		push_warning("Tried adding an army, but it was already on the list.")
		return

	var id: int = specific_id
	if not _unique_id_system.is_id_valid(specific_id):
		id = _unique_id_system.new_unique_id()
	elif not _unique_id_system.is_id_available(specific_id):
		push_error(
				"Specified army id is not unique."
				+ " (id: " + str(specific_id) + ")"
		)
		id = _unique_id_system.new_unique_id()
	else:
		_unique_id_system.claim_id(specific_id)

	army.id = id
	army.destroyed.connect(remove_army)
	_list.append(army)
	army_added.emit(army)


func remove_army(army: Army) -> void:
	if not _list.has(army):
		push_warning("Tried removing an army, but it wasn't on the list.")
		return

	army.destroyed.disconnect(remove_army)
	_list.erase(army)
	army_removed.emit(army)


## Returns a new copy of the list.
func list() -> Array[Army]:
	return _list.duplicate()


## Merges given armies when applicable.
##
## When more than one [Army] is controlled by the same [Country]
## in the same [Province], it's possible to merge them into one single [Army].
func merge_armies(armies_in_province: ArmiesInProvince) -> void:
	var armies_to_merge: Array[Army] = armies_in_province.list.duplicate()
	var number_of_armies: int = armies_to_merge.size()
	for i in number_of_armies:
		var army1: Army = armies_to_merge[i]
		for j in range(i + 1, number_of_armies):
			var army2: Army = armies_to_merge[j]
			if (
					army1.owner_country.id == army2.owner_country.id
					and army1.movements_made() == army2.movements_made()
			):
				army2.army_size.add(army1.army_size.current_size())
				remove_army(army1)
				break


## Returns a new list of all armies located in given [Province]
## that are controlled by given [Country].
func armies_of_country_in_province(
		country: Country, province: Province
) -> Array[Army]:
	var output: Array[Army] = []
	for army in _list:
		if army.province() == province and army.owner_country == country:
			output.append(army)
	return output


## Returns a new list of all active armies that are
## owned by given [Country] in given [Province].
## An [Army] is said to be "active" when it is able to perform actions.
func active_armies(country: Country, province: Province) -> Array[Army]:
	var output: Array[Army] = []
	for army in _list:
		if (
				army.province() == province
				and army.owner_country == country
				and army.is_able_to_move()
		):
			output.append(army)
	return output


## Returns the [Army] that has given id.
## If there is no such army, returns [code]null[/code].
func army_from_id(id: int) -> Army:
	for army in _list:
		if army.id == id:
			return army
	return null


func id_system() -> UniqueIdSystem:
	return _unique_id_system
