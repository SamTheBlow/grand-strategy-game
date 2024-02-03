class_name Buildings
extends Node
## Container class for buildings.


var _buildings: Array[Building]


func add(building: Building) -> void:
	_buildings.append(building)
	add_child(building)
