class_name Armies
## An encapsulated list of [Army] objects.
## Provides utility functions for manipulating the list and
## for accessing a specific [Army] or a specific subset of the list.

signal army_added(army: Army)
signal army_removed(army: Army)

var _list: Array[Army] = []
var _unique_id_system := UniqueIdSystem.new()


## If given army's id is invalid (i.e. a negative number),
## automatically gives it a new unique id.
##
## No effect if given army's id is already in use,
## or if given army is already in the list.
func add(army: Army) -> void:
	if _list.has(army):
		push_warning("Army is already in the list.")
		return
	if not _unique_id_system.is_id_valid(army.id):
		army.id = _unique_id_system.new_unique_id()
	elif not _unique_id_system.is_id_available(army.id):
		push_warning("Army id is already in use. (id: " + str(army.id) + ")")
		return
	else:
		_unique_id_system.claim_id(army.id)

	army.destroyed.connect(remove_army)
	_list.append(army)
	army_added.emit(army)


## No effect if given army is not in the list.
func remove_army(army: Army) -> void:
	if not _list.has(army):
		push_warning("Army is not in the list.")
		return

	army.destroyed.disconnect(remove_army)
	_list.erase(army)
	army_removed.emit(army)


## Returns a new copy of the list.
func list() -> Array[Army]:
	return _list.duplicate()


## Resets all internal data.
func reset() -> void:
	_list = []
	_unique_id_system = UniqueIdSystem.new()


## Merges given armies when applicable.
##
## When more than one [Army] is controlled by the same [Country]
## in the same [Province], it's possible to merge them into one single [Army].
func merge_armies(
		armies_in_province: ArmiesInProvince, playing_country: Country
) -> void:
	var armies_to_merge: Array[Army] = armies_in_province.list.duplicate()
	var number_of_armies: int = armies_to_merge.size()
	for i in number_of_armies:
		var army1: Army = armies_to_merge[i]
		for j in range(i + 1, number_of_armies):
			var army2: Army = armies_to_merge[j]
			if (
					army1.owner_country == army2.owner_country
					and (
							army1.owner_country != playing_country
							or army1.movements_made() == army2.movements_made()
					)
			):
				army2.army_size.add(army1.army_size.current_size())
				remove_army(army1)
				break


## Returns the [Army] that has given id.
## If there is no such army, returns [code]null[/code].
func army_from_id(id: int) -> Army:
	for army in _list:
		if army.id == id:
			return army
	return null


func id_system() -> UniqueIdSystem:
	return _unique_id_system
