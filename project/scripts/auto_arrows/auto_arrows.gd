class_name AutoArrows
## List of [AutoArrow] objects.
## Provides useful functions and signals.


signal arrow_added(auto_arrow: AutoArrow)
signal arrow_removed(auto_arrow: AutoArrow)

var _list: Array[AutoArrow] = []


func add(auto_arrow: AutoArrow) -> void:
	if has_equivalent_in_list(auto_arrow):
		return
	
	_list.append(auto_arrow)
	arrow_added.emit(auto_arrow)


## You don't have to pass an exact reference.
## Any [AutoArrow] that is considered equivalent to given arrow will be removed.
func remove(auto_arrow: AutoArrow) -> void:
	var list_arrow: AutoArrow
	
	if _list.has(auto_arrow):
		list_arrow = auto_arrow
	else:
		for arrow in _list:
			if auto_arrow.is_equivalent_to(arrow):
				list_arrow = arrow
				break
	
	if list_arrow == null:
		push_warning(
				"Tried removing an AutoArrow, but "
				+ "there was no equivalent arrow on the list."
		)
		return
	
	_list.erase(list_arrow)
	arrow_removed.emit(list_arrow)


## Removes from this list all autoarrows whose source province is given province.
func remove_all_from_province(source_province: Province) -> void:
	for auto_arrow in list():
		if auto_arrow.source_province == source_province:
			remove(auto_arrow)


## Returns a new copy of the list.
func list() -> Array[AutoArrow]:
	return _list.duplicate()


## Returns true if this autoarrow or an equivalent of it is already in the list.
func has_equivalent_in_list(auto_arrow: AutoArrow) -> bool:
	for arrow in _list:
		if arrow.is_equivalent_to(auto_arrow):
			return true
	return false
