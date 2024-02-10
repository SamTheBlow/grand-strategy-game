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
		army.province().armies.remove_child(army)
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
