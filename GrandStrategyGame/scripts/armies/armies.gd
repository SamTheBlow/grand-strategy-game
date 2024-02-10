class_name Armies
## Class responsible for managing a world's armies.


var armies: Array[Army] = []


func add_army(army: Army) -> void:
	if armies.has(army):
		print_debug(
				"Tried adding an army when it already was in the game."
		)
		return
	
	army.destroyed.connect(remove_army)
	armies.append(army)


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


func armies_in_province(province: Province) -> Array[Army]:
	var output: Array[Army] = []
	for army in armies:
		if army.province() == province:
			output.append(army)
	return output
