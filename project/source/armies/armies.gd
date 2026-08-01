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


## Removes given army, using given [UndoRedo] system.
## Ensures that when we undo, everything is exactly as it was before.
func undo_redo_remove(
		army: Army,
		undo_redo: UndoRedo,
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


func _restore_province_position(
		army: Army,
		province_index: int,
		armies_in_each_province: ArmiesInEachProvince
) -> void:
	armies_in_each_province.in_province_id(army.province_id()).move_army(
			army, province_index
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
