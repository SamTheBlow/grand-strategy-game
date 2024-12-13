class_name BuildingVisualsSetup
extends Node
## Adds and removes building visuals to match given [Buildings].

## The nodes will be added as children of this node.
## If left null, they will be added as children of this node.
@export var _visuals_parent: Node

## The scene's root node must extend [Node2D].
@export var _fortress_visuals_2d_scene: PackedScene

var buildings: Buildings:
	set(value):
		_reset()
		buildings = value
		# This is so that you can set spawn_position after setting buildings
		# and it'll still spawn them at the new spawn position
		_initialize.call_deferred()

## Default spawn point of all new buildings, relative to the parent node.
var spawn_position: Vector2

# This list is for cleaning up the nodes when needed
var _list: Array[Node] = []


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
		return

	var new_fortress := _fortress_visuals_2d_scene.instantiate() as Node2D
	new_fortress.position = spawn_position

	var parent_node: Node = _visuals_parent if _visuals_parent != null else self
	parent_node.add_child.call_deferred(new_fortress)

	_list.append(new_fortress)


func _on_building_added(building: Building) -> void:
	_add_building(building)
