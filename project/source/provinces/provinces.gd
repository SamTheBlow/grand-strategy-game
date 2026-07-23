class_name Provinces
## An encapsulated list of [Province]s. Provides useful functions and signals.

signal added(province: Province)
signal removed(province: Province)
signal province_owner_changed(province: Province)
signal building_added(building: Building)
signal building_removed(building: Building)

## The list.
## Maps a province id to a province.
## We use a dictionary for performance reasons.
var _list: Dictionary[int, Province] = {}

## Tracks the insertion order of provinces.
## Ensures that adding, removing and re-adding
## a province preserves the insertion order.
var _ordered_ids: Array[int] = []

var _unique_id_system := UniqueIdSystem.new()


## If given province's id is invalid (i.e. a negative number),
## automatically gives it a new unique id.
##
## No effect if given province's id is already in use,
## or if given province is already in the list.
func add(province: Province) -> void:
	_add(province)


func remove(province_id: int) -> void:
	if not _list.has(province_id):
		return
	var province: Province = _list[province_id]

	province.owner_changed.disconnect(province_owner_changed.emit)
	province.buildings.added.disconnect(building_added.emit)
	province.buildings.removed.disconnect(building_removed.emit)
	_list.erase(province_id)
	_ordered_ids.erase(province_id)

	# We have to unclaim the id because, if we want to bring this province
	# back in the list later with the same id, the id needs to not be in use.
	_unique_id_system.unclaim_id(province_id)

	# Remove any link to this province
	for list_province_id in _list:
		_list[list_province_id].linked_province_ids().erase(province_id)

	removed.emit(province)


## Removes a province, using given [UndoRedo] system.
## Ensures that when we undo, everything is exactly as it was before.
func undo_redo_remove(province: Province, undo_redo: UndoRedo) -> void:
	undo_redo.create_action("Delete province")
	undo_redo.add_do_method(remove.bind(province.id))

	# Ensure the province's position in the list is restored on undo
	var province_index: int = _ordered_ids.find(province.id)
	undo_redo.add_undo_method(_add.bind(province, province_index))

	# Ensure the provinces linked to this province
	# have their link restored on undo
	for other_province: Province in _list.values():
		if (
				other_province != province
				and other_province.is_linked_to(province.id)
		):
			undo_redo.add_undo_method(
					other_province.add_link.bind(province.id)
			)

	undo_redo.commit_action()


## Removes all provinces in this list.
## Also resets the id system so that all ids become valid again.
func clear() -> void:
	for province_id in _list:
		remove(province_id)
	_ordered_ids = []
	_unique_id_system = UniqueIdSystem.new()


## Returns a new copy of the list.
func list() -> Array[Province]:
	var output: Array[Province] = []
	for province_id in _ordered_ids:
		output.append(_list[province_id])
	return output


## Returns the number of provinces in this list.
func size() -> int:
	return _list.size()


## Returns the position of given province in the list,
## or -1 if there is no province in this list with given id.
func position_of(province_id: int) -> int:
	return _ordered_ids.find(province_id)


## Returns a list of every province that's linked to given province.
## Returns an empty list if there is no province with given id.
func links_of(province_id: int) -> Array[Province]:
	var output: Array[Province] = []
	if not _list.has(province_id):
		return output
	for linked_province_id in _list[province_id].linked_province_ids():
		if _list.has(linked_province_id):
			output.append(_list[linked_province_id])
	return output


## Returns the list of all provinces representing given [Country]'s frontline.
## Provinces in the list are not necessarily under control of given country.
func provinces_on_frontline(country: Country) -> Array[Province]:
	var output: Array[Province] = []
	for province_id in _list:
		if _list[province_id].is_frontline(country, self):
			output.append(_list[province_id])
	return output


## Returns null if no province has the given id.
func province_from_id(id: int) -> Province:
	return _list[id] if _list.has(id) else null


## Keeps the insertion index a private feature.
func _add(province: Province, insertion_index: int = -1) -> void:
	if _list.has(province.id):
		print_debug("Province is already in the list.")
		return
	if not _unique_id_system.is_id_valid(province.id):
		province.id = _unique_id_system.new_unique_id()
	elif not _unique_id_system.is_id_available(province.id):
		print_debug(
				"Province id is already in use. (id: " + str(province.id) + ")"
		)
		return
	else:
		_unique_id_system.claim_id(province.id)

	_list[province.id] = province

	if insertion_index < 0 or insertion_index >= _ordered_ids.size():
		_ordered_ids.append(province.id)
	else:
		_ordered_ids.insert(insertion_index, province.id)

	province.owner_changed.connect(province_owner_changed.emit)
	province.buildings.added.connect(building_added.emit)
	province.buildings.removed.connect(building_removed.emit)
	added.emit(province)
