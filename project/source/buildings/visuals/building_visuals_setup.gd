class_name BuildingVisualsSetup
extends Node
## Adds and removes building visuals to match given [Buildings].

const _FORTRESS_VISUALS_SCENE := preload("uid://cwi4tinm2f73x") as PackedScene

## The nodes will be added as children of this node.
## If left null, they will be added as children of this node.
@export var _visuals_parent: Node

var buildings: Buildings:
	set(value):
		_reset()
		buildings = value
		# This is so that you can set spawn_position after setting buildings
		# and it'll still spawn them at the new spawn position
		_initialize.call_deferred()

var province: Province:
	set(value):
		province = value
		province.position_changed.connect(_on_province_position_changed)

# This list is for cleaning up the nodes when needed
var _list: Array[Node2D] = []


func _reset() -> void:
	NodeUtils.delete_nodes(_list)

	if buildings == null:
		return

	if buildings.added.is_connected(_on_building_added):
		buildings.added.disconnect(_on_building_added)


func _initialize() -> void:
	if buildings == null:
		return

	for building in buildings.list():
		_add_building(building)

	if not buildings.added.is_connected(_on_building_added):
		buildings.added.connect(_on_building_added)


func _add_building(building: Building) -> void:
	if building is not Fortress:
		push_warning("Unrecognized building type.")
		return

	var new_fortress := _FORTRESS_VISUALS_SCENE.instantiate() as Node2D
	new_fortress.position = province.position_fortress

	var parent_node: Node = (
			_visuals_parent if _visuals_parent != null else self
	)
	parent_node.add_child.call_deferred(new_fortress)

	_list.append(new_fortress)


func _on_building_added(building: Building) -> void:
	_add_building(building)


func _on_province_position_changed() -> void:
	for node_2d in _list:
		node_2d.position = province.position_fortress
