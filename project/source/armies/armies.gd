class_name Armies
## An encapsulated list of [Army] objects.

signal added(army: Army)
signal removed(army: Army)

## Maps each army to its unique id.
var _list: Dictionary[int, Army] = {}

## The order in which the items are in the list.
var _order: Array[int] = []

var _unique_id_system := UniqueIdSystem.new()


## If given army's id is invalid (i.e. a negative number),
## automatically gives it a new unique id.
##
## No effect if given army's id is already in use,
## or if given army is already in the list.
func add(army: Army) -> void:
	_add(army)


## No effect if given army is not in the list.
func remove(army: Army) -> void:
	if not _list.has(army.id):
		push_warning("Army is not in the list.")
		return

	army.size().became_too_small.disconnect(remove)
	_list.erase(army.id)
	_order.erase(army.id)

	# We have to unclaim the id because, if we want to bring this army
	# back in the list later with the same id, the id needs to not be in use.
	_unique_id_system.unclaim_id(army.id)

	removed.emit(army)


## Removes given army, using given [UndoRedoResource] system.
## Ensures that when we undo, everything is exactly as it was before.
func undo_redo_remove(
		army: Army,
		undo_redo: UndoRedoResource,
		armies_in_each_province: ArmiesInEachProvince
) -> void:
	undo_redo.create_action("Delete army")
	undo_redo.add_do_method(remove.bind(army))

	# Ensure the army's position in this list is restored on undo.
	var order_index: int = _order.find(army.id)
	undo_redo.add_undo_method(_add.bind(army, order_index))

	# Ensure the army's position in its province's list is restored on undo.
	if army.province_id() != -1:
		var province_index: int = (
				armies_in_each_province
				.in_province_id(army.province_id()).list.find(army)
		)
		undo_redo.add_undo_method(_restore_province_position.bind(
				army, province_index, armies_in_each_province
		))

	undo_redo.commit_action()


## Moves given army to a different province and/or a different position.
func undo_redo_move(
		army: Army,
		new_province_id: int,
		new_stack_index: int,
		undo_redo: UndoRedoResource,
		armies_in_each_province: ArmiesInEachProvince,
) -> void:
	var old_province_id: int = army.province_id()
	var old_armies_in_province: ArmiesInProvince = (
			armies_in_each_province.in_province_id(old_province_id)
	)
	var old_stack_index: int = old_armies_in_province.list.find(army)

	# Do nothing if army is already where it should be
	if (
			old_province_id == new_province_id
			and old_stack_index == new_stack_index
	):
		return

	undo_redo.create_action("Move army")

	# Move to new province
	if old_province_id != new_province_id:
		undo_redo.add_do_method(
				army.teleport_to_province.bind(new_province_id)
		)
		undo_redo.add_undo_method(
				army.teleport_to_province.bind(old_province_id)
		)

	# Move to new position
	undo_redo.add_do_method(
			armies_in_each_province.in_province_id(new_province_id)
			.move_army.bind(army, new_stack_index)
	)
	undo_redo.add_undo_method(
			old_armies_in_province.move_army.bind(army, old_stack_index)
	)

	undo_redo.commit_action()


## Returns a list of given armies along with their position in
## this list as well as their position in their province's army list.
func list_with_positions(
		army_list: Array[Army], armies_in_each_province: ArmiesInEachProvince
) -> Array[ArmyWithPositions]:
	var output: Array[ArmyWithPositions] = []

	for army in army_list:
		var order_index: int = _order.find(army.id)
		var province_index: int = (
				armies_in_each_province
				.in_province_id(army.province_id()).list.find(army)
		)
		output.append(ArmyWithPositions.new(army, order_index, province_index))

	return output


## Adds each army in given list, inserted at given position in this list,
## and inserted at given position in the province's army list.
func add_list_with_positions(
		armies_with_positions: Array[ArmyWithPositions],
		armies_in_each_province: ArmiesInEachProvince
) -> void:
	# Add each army to this list in the correct order.
	# At the same time, build a mapping of each province to its armies.
	armies_with_positions.sort_custom(
			func(a: ArmyWithPositions, b: ArmyWithPositions) -> bool:
				return a.armies_index < b.armies_index
	)
	var armies_of_province: Dictionary[int, Array] = {}
	for army_with_positions in armies_with_positions:
		_add(army_with_positions.army, army_with_positions.armies_index)

		var province_id: int = army_with_positions.army.province_id()
		if not armies_of_province.has(province_id):
			armies_of_province[province_id] = []
		armies_of_province[province_id].append(army_with_positions)

	# For each province, move each army to the correct position in the list.
	for province_id in armies_of_province:
		var province_armies: Array = armies_of_province[province_id]
		province_armies.sort_custom(
				func(a: ArmyWithPositions, b: ArmyWithPositions) -> bool:
					return a.province_index < b.province_index
		)
		for army_with_positions: ArmyWithPositions in province_armies:
			armies_in_each_province.in_province_id(province_id).move_army(
					army_with_positions.army,
					army_with_positions.province_index
			)


## Returns null if there is no army with given id.
func army_from_id(id: int) -> Army:
	return _list[id] if _list.has(id) else null


## Returns a new copy of the list.
func list() -> Array[Army]:
	var output: Array[Army] = []
	for id in _order:
		output.append(_list[id])
	return output


## Resets all internal data.
func reset() -> void:
	_list.clear()
	_order.clear()
	_unique_id_system = UniqueIdSystem.new()


## Merges given armies when applicable.
##
## When more than one [Army] is controlled by the same [Country]
## in the same [Province], it's possible to merge them into one single [Army].
func merge_armies(
		armies_in_province: ArmiesInProvince, playing_country: Country
) -> void:
	var armies_to_merge: Array[Army] = armies_in_province.list.duplicate()
	var number_of_armies: int = armies_to_merge.size()
	for i in number_of_armies:
		var army1: Army = armies_to_merge[i]
		for j in range(i + 1, number_of_armies):
			var army2: Army = armies_to_merge[j]
			if (
					army1.owner_country == army2.owner_country
					and (
							army1.owner_country != playing_country
							or army1.movements_made() == army2.movements_made()
					)
			):
				army2.size().value += army1.size().value
				remove(army1)
				break


func id_system() -> UniqueIdSystem:
	return _unique_id_system


## Keeps the insertion index a private feature.
func _add(army: Army, insertion_index: int = -1) -> void:
	if _list.has(army.id):
		push_warning("Army is already in the list.")
		return
	if not _unique_id_system.is_id_valid(army.id):
		army.id = _unique_id_system.new_unique_id()
	elif not _unique_id_system.is_id_available(army.id):
		push_warning("Army id is already in use. (id: " + str(army.id) + ")")
		return
	else:
		_unique_id_system.claim_id(army.id)

	_list[army.id] = army

	if insertion_index < 0 or insertion_index >= _order.size():
		_order.append(army.id)
	else:
		_order.insert(insertion_index, army.id)

	army.size().became_too_small.connect(remove.bind(army))

	added.emit(army)


func _restore_province_position(
		army: Army,
		province_index: int,
		armies_in_each_province: ArmiesInEachProvince
) -> void:
	armies_in_each_province.in_province_id(army.province_id()).move_army(
			army, province_index
	)
