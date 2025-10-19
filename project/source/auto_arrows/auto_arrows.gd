class_name AutoArrows
## Encapsulated list of [AutoArrow] objects.
## Provides useful functions and signals.

signal arrow_added(auto_arrow: AutoArrow)
signal arrow_removed(auto_arrow: AutoArrow)

var _list: Array[AutoArrow] = []


## No effect if an equivalent arrow is already in the list.
func add(auto_arrow: AutoArrow) -> void:
	if has_equivalent_in_list(auto_arrow):
		return

	_list.append(auto_arrow)
	arrow_added.emit(auto_arrow)


## Removes any equivalent [AutoArrow], no need to provide the exact reference.
## No effect if given arrow has no equivalent in the list.
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
		push_warning("There is no equivalent arrow to remove.")
		return

	_list.erase(list_arrow)
	arrow_removed.emit(list_arrow)


## Removes from this list all autoarrows
## whose source province is given province.
func remove_all_from_province(source_province_id: int) -> void:
	for auto_arrow in list():
		if auto_arrow.source_province_id() == source_province_id:
			remove(auto_arrow)


## Removes from this list all autoarrows that go from or to given province
## (even if the province id is invalid.)
func remove_all_with_province(province_id: int) -> void:
	for auto_arrow in list():
		if (
				auto_arrow.source_province_id() == province_id
				or auto_arrow.destination_province_id() == province_id
		):
			remove(auto_arrow)


## Returns a new copy of the list.
func list() -> Array[AutoArrow]:
	return _list.duplicate()


## Returns true if given AutoArrow, or an equivalent of it, is in the list.
func has_equivalent_in_list(auto_arrow: AutoArrow) -> bool:
	for arrow in _list:
		if arrow.is_equivalent_to(auto_arrow):
			return true
	return false


static func from_raw_data(raw_data: Variant) -> AutoArrows:
	if raw_data is not Array:
		return AutoArrowsWithInvalidData.new(raw_data)
	var raw_array: Array = raw_data

	var auto_arrows := AutoArrows.new()
	for arrow_data: Variant in raw_array:
		auto_arrows.add(AutoArrow.from_raw_data(arrow_data))
	return auto_arrows


func to_raw_data() -> Variant:
	var output: Array = []
	for auto_arrow in _list:
		output.append(auto_arrow.to_raw_data())
	return output


class AutoArrowsWithInvalidData extends AutoArrows:
	var _data: Variant

	func _init(data: Variant) -> void:
		_data = data

	func to_raw_data() -> Variant:
		if _list.is_empty():
			return _data
		return super()
