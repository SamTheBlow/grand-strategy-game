class_name MapListNode
extends VBoxContainer
## Shows a list of game maps for the user to select.


signal map_selected(map_id: int)

@export var id_system: MapIdSystem
## The scene's root node must extend [MapOptionNode].
@export var map_option_node_scene: PackedScene

var _list: Array[MapOptionNode] = []


func _ready() -> void:
	for child in get_children():
		if child is MapOptionNode:
			_list.append(child)


func add_map(file_path: String) -> void:
	# Don't add the map if it's already on the list
	for node in _list:
		if node.file_path == file_path:
			return
	
	var new_map := map_option_node_scene.instantiate() as MapOptionNode
	new_map.file_path = file_path
	new_map.id = id_system.new_unique_id()
	new_map.selected.connect(_on_map_selected)
	add_child(new_map)
	_list.append(new_map)


## Calls add_map for each file path in given array.
func add_maps(file_paths: PackedStringArray) -> void:
	for file_path in file_paths:
		add_map(file_path)


## May return null if there is no map with given id.
func map_with_id(map_id: int) -> MapOptionNode:
	for map_node in _list:
		if map_node.id == map_id:
			return map_node
	return null


func _on_map_selected(id: int) -> void:
	map_selected.emit(id)
