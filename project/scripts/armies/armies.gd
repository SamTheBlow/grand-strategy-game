class_name Armies
## An encapsulated list of [Army] objects.
## Provides utility functions for manipulating the list and
## for accessing a specific [Army] or a specific subset of the list.
##
## This class also provides functions to give you new unique ids
## for newly created armies that you wish to add to this list.
## See also: [member Army.id]


signal army_added(army: Army)

var _list: Array[Army] = []
var _claimed_ids: Array[int] = []


func add_army(army: Army) -> void:
	if _list.has(army):
		print_debug("Tried adding an army, but it was already on the list.")
		return
	
	if army_with_id(army.id):
		push_error(
				"Tried adding an army, but there is already an army "
				+ "with the same id! Operation cancelled."
		)
		return
	
	# If the army's id was claimed before, unclaim it
	var claimed_id_index: int = _claimed_ids.find(army.id)
	if claimed_id_index != -1:
		_claimed_ids.remove_at(claimed_id_index)
	
	army.destroyed.connect(remove_army)
	_list.append(army)
	army_added.emit(army)


func remove_army(army: Army) -> void:
	if not _list.has(army):
		print_debug("Tried removing an army, but it wasn't on the list.")
		return
	
	army.destroyed.disconnect(remove_army)
	_list.erase(army)
	army.removed.emit()


## Returns a new copy of the list.
func list() -> Array[Army]:
	return _list.duplicate()


## Merges all armies in given province when applicable.
##
## When more than one [Army] is controlled by the same [Country]
## in the same [Province], it's possible to merge them into one single [Army].
func merge_armies(province: Province) -> void:
	var armies_to_merge: Array[Army] = armies_in_province(province)
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


func armies_of_country(country: Country) -> Array[Army]:
	var output: Array[Army] = []
	for army in _list:
		if army.owner_country == country:
			output.append(army)
	return output


## Returns a new list of all armies located in given [Province].
func armies_in_province(province: Province) -> Array[Army]:
	var output: Array[Army] = []
	for army in _list:
		if army.province() == province:
			output.append(army)
	return output


## Returns a new list of all armies located in given [Province]
## that are controlled by given [Country].
func armies_of_country_in_province(
		owner_country: Country, province: Province
) -> Array[Army]:
	var output: Array[Army] = []
	for army in _list:
		if army.province() == province and army.owner_country == owner_country:
			output.append(army)
	return output


## Returns the [Army] that has given id.
## If there is no such army, returns [code]null[/code].
func army_with_id(id: int) -> Army:
	for army in _list:
		if army.id == id:
			return army
	return null


## Provides unique ids that are not used by any [Army] in the list.
## Use [param number_of_ids] to choose how many new ids you want to receive.
## ([param number_of_ids] must be 1 or more.)
## They will all be unique and different from each other, guaranteed!
## And, just like the new_unique_id function,
## this function returns different ids each time.
func new_unique_ids(number_of_ids: int) -> Array[int]:
	if number_of_ids < 1:
		push_error(
				"Asked for an invalid amount ("
				+ str(number_of_ids) + ") of new unique ids."
		)
		return []
	
	var new_ids: Array[int] = [0]
	for i in number_of_ids:
		var id_is_not_unique: bool = true
		while id_is_not_unique:
			id_is_not_unique = false
			for army in _list:
				if army.id == new_ids[i]:
					id_is_not_unique = true
					new_ids[i] += 1
					break
			for claimed_id in _claimed_ids:
				if claimed_id == new_ids[i]:
					id_is_not_unique = true
					new_ids[i] += 1
					break
		_claimed_ids.append(new_ids[i])
		if i != number_of_ids - 1:
			new_ids.append(new_ids[i] + 1)
	return new_ids


# TODO DRY. copy/paste from [Players] kind of
## Provides a new unique id that is not used by any [Army] in the list.
## The id will be as small as possible (0 or higher).
## Calling this function again will return a different id every time,
## so you don't need to worry about a different piece of code
## getting the same new id as yours.
func new_unique_id() -> int:
	var new_id: int = 0
	var id_is_not_unique: bool = true
	while id_is_not_unique:
		id_is_not_unique = false
		for army in _list:
			if army.id == new_id:
				id_is_not_unique = true
				new_id += 1
				break
		for claimed_id in _claimed_ids:
			if claimed_id == new_id:
				id_is_not_unique = true
				new_id += 1
				break
	_claimed_ids.append(new_id)
	return new_id


## Returns a list of all active armies that are
## owned by given [Country] in given [Province].
## An [Army] is said to be "active" when it is able to perform actions.
func active_armies(country: Country, province: Province) -> Array[Army]:
	var result: Array[Army] = []
	var province_armies: Array[Army] = armies_in_province(province)
	for army in province_armies:
		if army.owner_country == country and army.is_able_to_move():
			result.append(army)
	return result
