class_name Buildings
extends Node
## Represents a list of [Building] objects.
## Buildings added to this list become children of this node.


signal changed()

var _buildings: Array[Building]


func add(building: Building) -> void:
	_buildings.append(building)
	add_child(building)
	changed.emit()
