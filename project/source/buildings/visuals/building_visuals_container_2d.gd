class_name BuildingVisualsContainer2D
extends Node2D
## Adds/edits/removes building visuals to match those of given [Province].

const _BUILDING_VISUALS_SCENE: PackedScene = preload("uid://cwi4tinm2f73x")

var province: Province:
	set(value):
		if province != null:
			province.position_fortress_changed.disconnect(_on_position_changed)
			province.buildings.added.disconnect(_add_building)
			province.buildings.removed.disconnect(_remove_building)

		province = value

		if is_node_ready():
			_refresh()

		province.position_fortress_changed.connect(_on_position_changed)
		province.buildings.added.connect(_add_building)
		province.buildings.removed.connect(_remove_building)

## Maps buildings to their corresponding node, for easy access.
var _map: Dictionary[Building, BuildingVisuals2D] = {}


func _ready() -> void:
	if province != null:
		_refresh()


func _refresh() -> void:
	NodeUtils.delete_nodes(_map.values())
	_map.clear()

	for building in province.buildings.list():
		_add_building(building)


func _add_building(building: Building) -> void:
	if not is_node_ready():
		return

	var new_visuals := (
			_BUILDING_VISUALS_SCENE.instantiate() as BuildingVisuals2D
	)
	new_visuals.position = province.position_fortress
	new_visuals.building_data = building.data
	add_child(new_visuals)
	_map[building] = new_visuals


func _remove_building(building: Building) -> void:
	if not is_node_ready():
		return

	NodeUtils.delete_node(_map[building])
	_map.erase(building)


func _on_position_changed(new_value: Vector2) -> void:
	for building in _map:
		_map[building].position = new_value
