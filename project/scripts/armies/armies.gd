class_name Armies
## Class responsible for a list of [Army] objects.
## Provides utility functions for manipulating the list and
## for accessing a specific [Army] or a specific subset of the list.
##
## This class also provides functions that give you new unique ids
## for newly created armies that you wish to add to this list.
## However, keep in mind that this class is (currently) not responsible
## for ensuring that the armies all have a unique id.
## (See also: [member Army.id])


# TODO don't let the user manipulate the array directly
## Please do not add or remove items directly from this array:
## use [method Armies.add_army] and [method Armies.remove_army] instead.
var armies: Array[Army] = []


# TODO verify that the army's id is unique
## Adds an army to the list.
func add_army(army: Army) -> void:
	if armies.has(army):
		print_debug(
				"Tried adding an army when it already was in the game."
		)
		return
	
	army.destroyed.connect(remove_army)
	armies.append(army)


## Removes an army from the list.
func remove_army(army: Army) -> void:
	if not armies.has(army):
		print_debug(
				"Tried removing an army when it already wasn't in the game."
		)
		return
	
	army.destroyed.disconnect(remove_army)
	if army.province():
		army.province().army_stack.remove_child(army)
	armies.erase(army)


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
			if army1.owner_country().id == army2.owner_country().id:
				army2.army_size.add(army1.army_size.current_size())
				remove_army(army1)
				break


## Returns a new list of all armies located in given [Province].
func armies_in_province(province: Province) -> Array[Army]:
	var output: Array[Army] = []
	for army in armies:
		if army.province() == province:
			output.append(army)
	return output


## Returns the [Army] that has given id.
## If there is no such [Army], returns [code]null[/code].
func army_with_id(id: int) -> Army:
	for army in armies:
		if army.id == id:
			return army
	return null


# TODO: There is an extremely rare chance that this returns duplicate IDs!
## Returns unique ids that aren't used by any [Army] in this list.
## Use [param number_of_ids] to choose how many new ids you want to receive.
func new_unique_army_ids(number_of_ids: int) -> Array[int]:
	var result: Array[int] = []
	for i in number_of_ids:
		result.append(new_unique_army_id())
	return result


## Returns a unique id that isn't used by any [Army] in this list.
func new_unique_army_id() -> int:
	var new_id: int
	var id_is_unique: bool = false
	while not id_is_unique:
		new_id = randi()
		id_is_unique = true
		for army in armies:
			if army.id == new_id:
				id_is_unique = false
				break
	return new_id


## Returns a list of all active armies that are
## owned by given [Country] in given [Province].
## An [Army] is said to be "active" when it is able to perform actions.
func active_armies(country: Country, province: Province) -> Array[Army]:
	var result: Array[Army] = []
	var province_armies: Array[Army] = armies_in_province(province)
	for army in province_armies:
		if army.owner_country() == country and army.is_able_to_move():
			result.append(army)
	return result
