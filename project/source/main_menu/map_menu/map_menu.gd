class_name MapMenu
extends MarginContainer
## In the main menu, this is the tab for choosing the map.
## Shows all the available maps (built-in and custom).
## Has buttons for importing (or scanning for) custom maps.
## Clicking on a map selects it and emits a signal.
## There must be a map selected, and only one map can be selected at a time.


var map_menu_state: MapMenuState:
	set = set_map_menu_state

var _selected_map_node: MapOptionNode

@onready var _sync := %MapMenuSync as MapMenuSync
@onready var _import_dialog := %ImportDialog as FileDialog
@onready var _map_list_builtin: MapListBuiltin = (
		%MapListBuiltin as MapListBuiltin
)
@onready var _map_list_custom: MapListNode = %MapListCustom as MapListNode
@onready var _scroll_builtin := %ScrollBuiltin as ScrollContainer
@onready var _scroll_custom := %ScrollCustom as ScrollContainer


func _ready() -> void:
	_update_map_menu_state()


# This is its own function so that other nodes can have signals that call this.
func set_map_menu_state(value: MapMenuState) -> void:
	_disconnect_signals()
	map_menu_state = value
	_connect_signals()
	_update_map_menu_state()


func selected_map() -> MapMetadata:
	return _selected_map_node.map_metadata


func _map_node_with_id(map_id: int) -> MapOptionNode:
	for map_list: MapListNode in [_map_list_builtin, _map_list_custom]:
		var map_option_node: MapOptionNode = map_list.map_with_id(map_id)
		if map_option_node != null:
			return map_option_node
	push_error(
			"Cannot find map node in map selection menu (id: "
			+ str(map_id) + ")"
	)
	return null


func _update_map_menu_state() -> void:
	if map_menu_state == null or not is_node_ready():
		return
	
	_sync.active_state = map_menu_state
	# Only set the current state as the local state
	# the first time this function is called.
	if _sync.local_state == null:
		_sync.local_state = map_menu_state
	
	(%CustomMapImport as CustomMapImport).map_menu_state = map_menu_state
	
	# Load the built-in maps if they aren't loaded already
	if map_menu_state.builtin_maps().size() == 0:
		for builtin_map_file_path in _map_list_builtin.builtin_maps:
			var builtin_map: MapMetadata = (
					MapMetadata.from_file_path(builtin_map_file_path)
			)
			if builtin_map == null:
				continue
			map_menu_state.add_builtin_map(builtin_map)
	
	# Remove any existing [MapOptionNode]
	_map_list_builtin.clear()
	_map_list_custom.clear()
	
	# Load the [MapOptionNode]s
	var builtin_maps: Array[MapMetadata] = map_menu_state.builtin_maps()
	_map_list_builtin.add_maps(builtin_maps, 0)
	_map_list_custom.add_maps(map_menu_state.custom_maps(), builtin_maps.size())
	
	# If no map is selected, select the first map on the list by default
	if map_menu_state.selected_map_id() == -1:
		map_menu_state.set_selected_map_id(0)
	
	# Highlight the selected map
	_on_map_selected()
	
	# Scroll down so that the selected map is visible on screen
	_scroll_to_selected_map()


func _scroll_to_selected_map() -> void:
	if _selected_map_node == null:
		return
	
	var scroll_container: ScrollContainer
	var map_list: MapListNode
	
	if map_menu_state.is_selected_map_builtin():
		scroll_container = _scroll_builtin
		map_list = _map_list_builtin
	else:
		scroll_container = _scroll_custom
		map_list = _map_list_custom
	
	# Calculate the amount of vertical scroll to be done
	var scroll_vertical: int = 0
	var separation: int = map_list.get_theme_constant("separation")
	for node in map_list.get_children():
		if node == _selected_map_node:
			break
		if node is not Control:
			continue
		var control := node as Control
		scroll_vertical += floori(control.size.y) + separation
	
	scroll_container.set_v_scroll.call_deferred(scroll_vertical)


func _connect_signals() -> void:
	if map_menu_state == null:
		return
	
	if not map_menu_state.selected_map_changed.is_connected(_on_map_selected):
		map_menu_state.selected_map_changed.connect(_on_map_selected)
	if not map_menu_state.custom_map_added.is_connected(_on_custom_map_added):
		map_menu_state.custom_map_added.connect(_on_custom_map_added)
	if not map_menu_state.state_changed.is_connected(_on_state_changed):
		map_menu_state.state_changed.connect(_on_state_changed)


func _disconnect_signals() -> void:
	if map_menu_state == null:
		return
	
	if map_menu_state.selected_map_changed.is_connected(_on_map_selected):
		map_menu_state.selected_map_changed.disconnect(_on_map_selected)
	if map_menu_state.custom_map_added.is_connected(_on_custom_map_added):
		map_menu_state.custom_map_added.disconnect(_on_custom_map_added)
	if map_menu_state.state_changed.is_connected(_on_state_changed):
		map_menu_state.state_changed.disconnect(_on_state_changed)


## Called when the user clicks on a map to select it.
func _on_map_clicked(map_id: int) -> void:
	map_menu_state.set_selected_map_id(map_id)


## Called when the map menu state emits the signal "selected_map_changed".
func _on_map_selected() -> void:
	if _selected_map_node != null:
		_selected_map_node.deselect()
	_selected_map_node = _map_node_with_id(map_menu_state.selected_map_id())
	_selected_map_node.select()


func _on_custom_map_added(map_metadata: MapMetadata) -> void:
	var new_map_id: int = map_menu_state.number_of_maps() - 1
	_map_list_custom.add_map(map_metadata, new_map_id)


func _on_state_changed(_state: MapMenuState) -> void:
	_update_map_menu_state()


func _on_import_button_pressed() -> void:
	_import_dialog.show()
