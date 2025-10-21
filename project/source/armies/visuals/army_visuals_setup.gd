class_name ArmyVisualsSetup
extends Node
## Creates and deletes [ArmyVisuals2D] nodes for each army in given [Armies],
## and moves them to the correct [ProvinceVisuals2D].

## The scene's root node must extend [ArmyVisuals2D].
const _ARMY_VISUALS_SCENE := preload("uid://eso260jnknd4") as PackedScene

var _is_setup: bool = false
var _armies: Armies
var _playing_country: PlayingCountry

## Each army mapped to its visuals.
var _map: Dictionary[Army, ArmyVisuals2D] = {}
var _armies_with_no_visuals: Array[Army] = []

@onready var _provinces_container := %Provinces as ProvinceVisualsContainer2D


func _ready() -> void:
	if _is_setup:
		_update()


func setup(armies: Armies, playing_country: PlayingCountry) -> void:
	if _is_setup and is_node_ready():
		_disconnect_signals()

	_armies = armies
	_playing_country = playing_country

	_is_setup = true

	if is_node_ready():
		_update()


func _update() -> void:
	_remove_all_armies()

	for army in _armies.list():
		_add_army(army)

	_connect_signals()


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
	_map = {}
	_armies_with_no_visuals = []


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
		_remove_visuals_no_signal(_map[army])
		province_visuals.add_army(_map[army])
	elif _armies_with_no_visuals.has(army):
		_armies_with_no_visuals.erase(army)
		_map[army] = _new_army_visuals(army)
		province_visuals.add_army(_map[army])
	else:
		push_error("Army is not in the list.")


func _new_army_visuals(army: Army) -> ArmyVisuals2D:
	var new_army_visuals := _ARMY_VISUALS_SCENE.instantiate() as ArmyVisuals2D
	new_army_visuals.army = army
	new_army_visuals.playing_country = _playing_country
	new_army_visuals.tree_exited.connect(_on_visuals_tree_exited.bind(army))
	return new_army_visuals


## Removes the army visuals from the scene tree,
## without calling "_on_visuals_tree_exited".
func _remove_visuals_no_signal(army_visuals: ArmyVisuals2D) -> void:
	army_visuals.tree_exited.disconnect(_on_visuals_tree_exited)
	if army_visuals.get_parent() != null:
		army_visuals.get_parent().remove_child(army_visuals)
	army_visuals.tree_exited.connect(
			_on_visuals_tree_exited.bind(army_visuals.army)
	)


func _delete_visuals(army_visuals: ArmyVisuals2D) -> void:
	army_visuals.tree_exited.disconnect(_on_visuals_tree_exited)
	NodeUtils.delete_node(army_visuals)


func _connect_signals() -> void:
	_armies.army_added.connect(_add_army)
	_armies.army_removed.connect(_remove_army)


func _disconnect_signals() -> void:
	_armies.army_added.disconnect(_add_army)
	_armies.army_removed.disconnect(_remove_army)


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
