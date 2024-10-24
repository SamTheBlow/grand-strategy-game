class_name MapTabNode
extends MarginContainer
## In the main menu, this is the tab for choosing the map.
## Shows all the available maps (built-in and custom).
## Has buttons for importing (or scanning for) custom maps.
## Clicking on a map selects it and emits a signal.
## There must be a map selected, and only one map can be selected at a time.


signal map_selected(map_file_path: String)

var _selected_map_id: int = 0

@onready var _map_lists: Array[MapListNode] = [
	%MapListBuiltin as MapListNode,
	%MapListCustom as MapListNode,
]

@onready var _import_dialog := %ImportDialog as FileDialog


func _ready() -> void:
	_map_from_id(_selected_map_id).select()


func selected_map_file_path() -> String:
	return _map_from_id(_selected_map_id).file_path


func _map_from_id(map_id: int) -> MapOptionNode:
	for map_list in _map_lists:
		var map_option_node: MapOptionNode = map_list.map_with_id(map_id)
		if map_option_node != null:
			return map_option_node
	push_error(
			"Cannot find map node in map selection menu (id: "
			+ str(map_id) + ")"
	)
	return null


func _on_map_selected(map_id: int) -> void:
	_map_from_id(_selected_map_id).deselect()
	_selected_map_id = map_id
	_map_from_id(_selected_map_id).select()
	map_selected.emit(selected_map_file_path())


func _on_import_button_pressed() -> void:
	_import_dialog.show()
