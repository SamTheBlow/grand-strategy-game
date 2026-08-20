class_name Provinces
## An encapsulated list of [Province]s. Provides useful functions and signals.

signal added(province: Province)
signal removed(province: Province)
signal province_owner_changed(province: Province)
signal building_added(building: Building)
signal building_removed(building: Building)

## The list, as an array.
## It's exposed for performance reasons. Do not edit this list!
var list: Array[Province] = []

## The list, as a dictionary. Maps a province id to its province.
## Use this list to quickly get a province by its id.
## It's exposed for performance reasons. Do not edit this list!
var map: Dictionary[int, Province] = {}

var _unique_id_system := UniqueIdSystem.new()


## If given province's id is invalid (i.e. a negative number),
## automatically gives it a new unique id.
##
## No effect if given province's id is already in use,
## or if given province is already in the list.
func add(province: Province) -> void:
	_add(province)


func remove(province_id: int) -> void:
	if not map.has(province_id):
		return
	var province: Province = map[province_id]

	province.owner_changed.disconnect(province_owner_changed.emit)
	province.buildings.added.disconnect(building_added.emit)
	province.buildings.removed.disconnect(building_removed.emit)
	map.erase(province_id)
	list.erase(province)

	# We have to unclaim the id because, if we want to bring this province
	# back in the list later with the same id, the id needs to not be in use.
	_unique_id_system.unclaim_id(province_id)

	# Remove any link to this province
	for other_province in list:
		other_province.linked_province_ids().erase(province_id)

	removed.emit(province)


## Removes a province, using given [UndoRedoResource] system.
## Ensures that when we undo, everything is exactly as it was before.
func undo_redo_remove(
		province: Province,
		undo_redo: UndoRedoResource,
		armies: Armies,
		armies_in_each_province: ArmiesInEachProvince
) -> void:
	# Save this province's armies and their positions
	var armies_with_positions: Array[ArmyWithPositions] = (
			armies.list_with_positions(
					armies_in_each_province.dictionary[province.id]
					.ordered_list,
					armies_in_each_province
			)
	)

	undo_redo.create_action("Delete province")
	undo_redo.add_do_method(remove.bind(province.id))

	# Ensure the province's position in the list is restored on undo
	undo_redo.add_undo_method(_add.bind(province, list.find(province)))

	# Ensure the provinces linked to this province
	# have their link restored on undo
	for other_province in list:
		if (
				other_province != province
				and other_province.is_linked_to(province.id)
		):
			undo_redo.add_undo_method(
					other_province.add_link.bind(province.id)
			)

	# Ensure the province's armies are restored on undo
	undo_redo.add_undo_method(armies.add_list_with_positions.bind(
			armies_with_positions, armies_in_each_province
	))

	undo_redo.commit_action()


## Removes all provinces in this list.
## Also resets the id system so that all ids become valid again.
func clear() -> void:
	for province_id: int in map.keys():
		remove(province_id)
	_unique_id_system = UniqueIdSystem.new()


## Returns a list of every province that's linked to given province.
## Returns an empty list if there is no province with given id.
func links_of(province_id: int) -> Array[Province]:
	var output: Array[Province] = []
	if not map.has(province_id):
		return output
	for linked_province_id in map[province_id].linked_province_ids():
		if map.has(linked_province_id):
			output.append(map[linked_province_id])
	return output


## Returns the list of all provinces representing given [Country]'s frontline.
## Provinces in the list are not necessarily under control of given country.
func provinces_on_frontline(country: Country) -> Array[Province]:
	var output: Array[Province] = []
	for province in list:
		if province.is_frontline(country, self):
			output.append(province)
	return output


## Keeps the insertion index a private feature.
func _add(province: Province, insertion_index: int = -1) -> void:
	if map.has(province.id):
		push_warning("Province is already in the list.")
		return
	if not _unique_id_system.is_id_valid(province.id):
		province.id = _unique_id_system.new_unique_id()
	elif not _unique_id_system.is_id_available(province.id):
		push_warning(
				"Province id is already in use. (id: " + str(province.id) + ")"
		)
		return
	else:
		_unique_id_system.claim_id(province.id)

	map[province.id] = province

	if insertion_index < 0 or insertion_index >= list.size():
		list.append(province)
	else:
		list.insert(insertion_index, province)

	province.owner_changed.connect(province_owner_changed.emit)
	province.buildings.added.connect(building_added.emit)
	province.buildings.removed.connect(building_removed.emit)
	added.emit(province)
