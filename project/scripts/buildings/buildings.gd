class_name Buildings
extends Node
## A list of [Building] objects.
## Buildings added to this list become children of this node.


signal changed()

var _list: Array[Building]


func add(building: Building) -> void:
	_list.append(building)
	add_child(building)
	changed.emit()


## Returns a new copy of the list.
func list() -> Array[Building]:
	return _list.duplicate()


func number_of_type(building_type: Building.Type) -> int:
	var output: int = 0
	for building in _list:
		if building.type() == building_type:
			output += 1
	return output
