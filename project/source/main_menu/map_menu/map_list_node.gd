class_name MapListNode
extends VBoxContainer
## Shows a list of game maps for the user to select.


signal map_selected(map_id: int)

## The scene's root node must extend [MapOptionNode].
@export var map_option_node_scene: PackedScene
## The scene's root node must extend [MapSettings].
@export var map_settings_scene: PackedScene

var _list: Array[MapOptionNode] = []


func add_map(map_metadata: MapMetadata, map_id: int) -> void:
	var new_map := map_option_node_scene.instantiate() as MapOptionNode
	new_map.map_metadata = map_metadata
	new_map.id = map_id
	new_map.selected.connect(_on_map_selected)
	
	var map_settings := map_settings_scene.instantiate() as MapSettings
	new_map.map_settings = map_settings
	
	add_child(new_map)
	add_child(map_settings)
	_list.append(new_map)


## Calls add_map for each file path in given array.
func add_maps(map_data_array: Array[MapMetadata], starting_map_id: int) -> void:
	var map_id: int = starting_map_id
	for map_data in map_data_array:
		add_map(map_data, map_id)
		map_id += 1


func clear() -> void:
	for map_option_node in _list:
		remove_child(map_option_node)
	_list.clear()


## May return null if there is no map with given id.
func map_with_id(map_id: int) -> MapOptionNode:
	for map_node in _list:
		if map_node.id == map_id:
			return map_node
	return null


func _on_map_selected(id: int) -> void:
	map_selected.emit(id)
