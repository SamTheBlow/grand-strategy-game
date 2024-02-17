class_name Armies
## Class responsible for managing a world's armies.


var armies: Array[Army] = []


## Adds a new army to the game.
func add_army(army: Army) -> void:
	if armies.has(army):
		print_debug(
				"Tried adding an army when it already was in the game."
		)
		return
	
	army.destroyed.connect(remove_army)
	armies.append(army)


## Removes an army from the game.
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


## Merges all armies with the same owner country in given province.
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


## Gives a list of every army located in given province.
func armies_in_province(province: Province) -> Array[Army]:
	var output: Array[Army] = []
	for army in armies:
		if army.province() == province:
			output.append(army)
	return output


## Gives the army with given id. If there is no such army, returns null.
func army_with_id(id: int) -> Army:
	for army in armies:
		if army.id == id:
			return army
	return null


## WARNING: In extremely rare cases, may return duplicate IDs!
func new_unique_army_ids(number_of_ids: int) -> Array[int]:
	var result: Array[int] = []
	for i in number_of_ids:
		result.append(new_unique_army_id())
	return result


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


## Returns a list of all active armies
## with given owner country in given province.
func active_armies(country: Country, province: Province) -> Array[Army]:
	var result: Array[Army] = []
	var province_armies: Array[Army] = armies_in_province(province)
	for army in province_armies:
		if army.owner_country() == country and army.is_active:
			result.append(army)
	return result
