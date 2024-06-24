class_name AutoArrows


signal arrow_added(auto_arrow: AutoArrow)
signal arrow_removed(auto_arrow: AutoArrow)

var _list: Array[AutoArrow] = []


func add(auto_arrow: AutoArrow) -> void:
	if is_duplicate(auto_arrow):
		return
	auto_arrow.source_province_changed.connect(_on_property_changed)
	auto_arrow.destination_province_changed.connect(_on_property_changed)
	_list.append(auto_arrow)
	arrow_added.emit(auto_arrow)


## You don't have to pass an exact reference.
## Any [AutoArrow] that is considered a
## duplicate of the given arrow will be removed.
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
	
	list_arrow.source_province_changed.disconnect(_on_property_changed)
	list_arrow.destination_province_changed.disconnect(_on_property_changed)
	_list.erase(list_arrow)
	list_arrow.removed.emit()
	arrow_removed.emit(list_arrow)


func remove_all_from_province(source_province: Province) -> void:
	for auto_arrow in list():
		if auto_arrow.source_province == source_province:
			remove(auto_arrow)


## Returns a new copy of the list.
func list() -> Array[AutoArrow]:
	return _list.duplicate()


func is_duplicate(auto_arrow: AutoArrow) -> bool:
	for arrow in _list:
		if arrow == auto_arrow:
			continue
		if arrow.is_equivalent_to(auto_arrow):
			return true
	return false


func _on_property_changed(auto_arrow: AutoArrow) -> void:
	if is_duplicate(auto_arrow):
		remove(auto_arrow)
