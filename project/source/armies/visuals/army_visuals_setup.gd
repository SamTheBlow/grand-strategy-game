class_name ArmyVisualsSetup
extends Node
## Creates and deletes [ArmyVisuals2D] nodes for each army in given [Armies],
## and moves them to the correct [ProvinceVisuals2D].

## Emitted after a new army's visuals have been created and added to the tree.
signal army_visuals_created(army_visuals: ArmyVisuals2D)

## The scene's root node must extend [ArmyVisuals2D].
const _ARMY_VISUALS_SCENE := preload("uid://eso260jnknd4") as PackedScene

var _armies: Armies
var _playing_country: PlayingCountry
## Used to make the army stack order match the internal data.
var _armies_in_each_province: ArmiesInEachProvince

## Each army mapped to its visuals.
var _map: Dictionary[Army, ArmyVisuals2D] = {}
var _armies_with_no_visuals: Array[Army] = []

@onready var _provinces_container := %Provinces as ProvinceVisualsContainer2D


func setup(
		armies: Armies,
		playing_country: PlayingCountry,
		armies_in_each_province: ArmiesInEachProvince
) -> void:
	if not is_node_ready():
		ready.connect(
				setup.bind(armies, playing_country, armies_in_each_province),
				ConnectFlags.CONNECT_ONE_SHOT
		)
		return

	if _armies != null:
		_armies.added.disconnect(_add_army)
		_armies.removed.disconnect(_remove_army)
		_armies_in_each_province.army_reordered.disconnect(_move_army_in_stack)

		# Remove all
		_remove_all_armies()

	_armies = armies
	_playing_country = playing_country
	_armies_in_each_province = armies_in_each_province

	if _armies != null:
		# Add all
		for army in _armies.list():
			_add_army(army)

		_armies.added.connect(_add_army)
		_armies.removed.connect(_remove_army)
		_armies_in_each_province.army_reordered.connect(_move_army_in_stack)


func clear() -> void:
	setup(null, null, null)


## Returns the visuals for given army, or null if the army has no visuals.
func visuals_of(army: Army) -> ArmyVisuals2D:
	return _map.get(army)


## Returns all army visuals currently on the world map.
func all_visuals() -> Array[ArmyVisuals2D]:
	return _map.values()


func _add_army(army: Army) -> void:
	if _map.has(army) or _armies_with_no_visuals.has(army):
		push_error("Army is already in the list.")
		return

	_armies_with_no_visuals.append(army)
	_assign_to_province(army)
	army.province_changed.connect(_assign_to_province)


func _remove_army(army: Army) -> void:
	if _armies_with_no_visuals.has(army):
		army.province_changed.disconnect(_assign_to_province)
		_armies_with_no_visuals.erase(army)
	elif _map.has(army):
		army.province_changed.disconnect(_assign_to_province)
		_delete_visuals(_map[army])
		_map.erase(army)
	else:
		push_error("Army is not in the list.")


func _remove_all_armies() -> void:
	for army in _map:
		army.province_changed.disconnect(_assign_to_province)
		_delete_visuals(_map[army])
	for army in _armies_with_no_visuals:
		army.province_changed.disconnect(_assign_to_province)
	_map.clear()
	_armies_with_no_visuals.clear()


func _assign_to_province(army: Army) -> void:
	var province_visuals: ProvinceVisuals2D = (
			_provinces_container.visuals_of(army.province_id())
	)
	if province_visuals == null:
		if _map.has(army):
			_delete_visuals(_map[army])
			_map.erase(army)
			_armies_with_no_visuals.append(army)
		elif _armies_with_no_visuals.has(army):
			pass
		else:
			push_error("Army is not in the list.")
		return

	if _map.has(army):
		_remove_army(army)
		_add_army(army)
	elif _armies_with_no_visuals.has(army):
		_armies_with_no_visuals.erase(army)
		_map[army] = _new_army_visuals(army)
		province_visuals.add_army(_map[army])
		army_visuals_created.emit(_map[army])
	else:
		push_error("Army is not in the list.")


func _new_army_visuals(army: Army) -> ArmyVisuals2D:
	var new_army_visuals := _ARMY_VISUALS_SCENE.instantiate() as ArmyVisuals2D
	new_army_visuals.army = army
	new_army_visuals.playing_country = _playing_country
	new_army_visuals.tree_exited.connect(_on_visuals_tree_exited.bind(army))
	return new_army_visuals


func _delete_visuals(army_visuals: ArmyVisuals2D) -> void:
	army_visuals.tree_exited.disconnect(_on_visuals_tree_exited)
	NodeUtils.delete_node(army_visuals)


func _move_army_in_stack(army: Army, position_index: int) -> void:
	var province_visuals: ProvinceVisuals2D = (
			_provinces_container.visuals_of(army.province_id())
	)
	province_visuals.move_army(_map[army], position_index)


## If the army visuals are deleted from elsewhere,
## update internal state and try to create new visuals for the army.
func _on_visuals_tree_exited(army: Army) -> void:
	if not is_inside_tree():
		return

	if not _map.has(army):
		push_error("Army is not in the list.")
		return

	_map.erase(army)
	_armies_with_no_visuals.append(army)
	_assign_to_province(army)
