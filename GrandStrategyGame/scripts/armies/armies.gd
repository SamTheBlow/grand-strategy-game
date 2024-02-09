class_name Armies
## Class responsible for managing a world's armies.


var armies: Array[Army] = []


func add_army(army: Army) -> void:
	armies.append(army)
	army.province().armies.add_army(army)


func armies_in_province(province: Province) -> Array[Army]:
	var output: Array[Army] = []
	for army in armies:
		if army.province() == province:
			output.append(army)
	return output
