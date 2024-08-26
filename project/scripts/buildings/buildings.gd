class_name Buildings
## A list of [Building] objects.


signal added(building: Building)
signal changed()

var _list: Array[Building]


func add(building: Building) -> void:
	_list.append(building)
	added.emit(building)
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
