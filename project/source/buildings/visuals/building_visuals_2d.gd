class_name BuildingVisuals2D
extends Node2D
## Adds/edits/removes building visuals to match those of given [Province].

const _FORTRESS_VISUALS_SCENE := preload("uid://cwi4tinm2f73x") as PackedScene

var _is_setup: bool = false
var _province: Province

var _building_nodes: Array[Node2D] = []


func _ready() -> void:
	if _is_setup:
		_update()


func setup(province: Province) -> void:
	if _is_setup:
		_province.position_changed.disconnect(_on_province_position_changed)
		if is_node_ready():
			_province.buildings.added.disconnect(_add_building)
			_province.buildings.removed.disconnect(_remove_building)

	_province = province
	_is_setup = true

	_province.position_changed.connect(_on_province_position_changed)

	if is_node_ready():
		_update()


func _update() -> void:
	NodeUtils.delete_nodes(_building_nodes)
	_building_nodes = []

	for building in _province.buildings.list():
		_add_building(building)

	_province.buildings.added.connect(_add_building)
	_province.buildings.removed.connect(_remove_building)


func _add_building(building: Building) -> void:
	if building is not Fortress:
		push_warning("Unrecognized building type.")
		return

	var new_fortress := _FORTRESS_VISUALS_SCENE.instantiate() as Node2D
	new_fortress.position = _province.fortress_position()
	add_child(new_fortress)
	_building_nodes.append(new_fortress)


func _remove_building(building: Building) -> void:
	if building is not Fortress:
		push_warning("Unrecognized building type.")
		return

	NodeUtils.delete_nodes(_building_nodes)
	_building_nodes = []


func _on_province_position_changed() -> void:
	for building_node in _building_nodes:
		building_node.position = _province.fortress_position()
