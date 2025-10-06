class_name WorldDecorations
## An encapsulated list of [WorldDecoration]s.

signal added(decoration: WorldDecoration)
signal removed(decoration: WorldDecoration)

var _list: Array[WorldDecoration] = []


func _init(initial_list: Array[WorldDecoration] = []) -> void:
	_list = initial_list


func add(decoration: WorldDecoration) -> void:
	if _list.has(decoration):
		push_warning(
				"Tried to add a world decoration that is already on the list."
		)
		return
	_list.append(decoration)
	added.emit(decoration)


func remove(decoration: WorldDecoration) -> void:
	if not _list.has(decoration):
		push_warning(
				"Tried to remove a world decoration that isn't on the list."
		)
		return
	_list.erase(decoration)
	removed.emit(decoration)


## Returns a new copy of the list.
func list() -> Array[WorldDecoration]:
	return _list.duplicate()
