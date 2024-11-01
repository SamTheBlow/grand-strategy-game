class_name MapMenuState
## Data structure. Contains all the data related to the map selection menu.


## This is not emitted when updating the entire state at once.
signal selected_map_changed()
## This is not emitted when updating the entire state at once.
signal builtin_map_added(map_metadata: MapMetadata)
## This is not emitted when updating the entire state at once.
signal custom_map_added(map_metadata: MapMetadata)
## Emitted after the entire state is updated.
signal state_changed(this: MapMenuState)

const KEY_SELECTED_MAP: String = "selected_map_id"
const KEY_BUILTIN_MAP_LIST: String = "builtin_map_list"
const KEY_CUSTOM_MAP_LIST: String = "custom_map_list"

var _selected_map_id: int = -1
var _builtin_maps: Array[MapMetadata] = []
var _custom_maps: Array[MapMetadata] = []


func selected_map_id() -> int:
	return _selected_map_id


func set_selected_map_id(map_id: int) -> void:
	_selected_map_id = map_id
	selected_map_changed.emit()


## Returns true if the selected map id
## is a valid index in the built-in maps array.
func is_selected_map_builtin() -> bool:
	return _selected_map_id >= 0 and _selected_map_id < _builtin_maps.size()


func builtin_maps() -> Array[MapMetadata]:
	return _builtin_maps.duplicate()


func add_builtin_map(map_metadata: MapMetadata) -> void:
	_builtin_maps.append(map_metadata)
	builtin_map_added.emit(map_metadata)


func custom_maps() -> Array[MapMetadata]:
	return _custom_maps.duplicate()


func add_custom_map(map_metadata: MapMetadata) -> void:
	_custom_maps.append(map_metadata)
	custom_map_added.emit(map_metadata)


func number_of_maps() -> int:
	return _builtin_maps.size() + _custom_maps.size()


## Returns the entire state as a Dictionary. Useful for networking.
func get_raw_state() -> Dictionary:
	var _raw_builtin_maps: Array = []
	for builtin_map in _builtin_maps:
		_raw_builtin_maps.append(builtin_map.to_dict())
	
	var _raw_custom_maps: Array = []
	for custom_map in _custom_maps:
		_raw_custom_maps.append(custom_map.to_dict())
	
	return {
		KEY_SELECTED_MAP: _selected_map_id,
		KEY_BUILTIN_MAP_LIST: _raw_builtin_maps,
		KEY_CUSTOM_MAP_LIST: _raw_custom_maps,
	}


## Updates the entire state to match given Dictionary. Useful for networking.
func set_raw_state(data: Dictionary) -> void:
	_builtin_maps = []
	if ParseUtils.dictionary_has_array(data, KEY_BUILTIN_MAP_LIST):
		var map_list: Array = data[KEY_BUILTIN_MAP_LIST]
		_populate_map_list(_builtin_maps, map_list)
	
	_custom_maps = []
	if ParseUtils.dictionary_has_array(data, KEY_CUSTOM_MAP_LIST):
		var map_list: Array = data[KEY_CUSTOM_MAP_LIST]
		_populate_map_list(_custom_maps, map_list)
	
	_selected_map_id = -1
	if ParseUtils.dictionary_has_number(data, KEY_SELECTED_MAP):
		_selected_map_id = ParseUtils.dictionary_int(data, KEY_SELECTED_MAP)
	
	state_changed.emit(self)


func _populate_map_list(map_list: Array[MapMetadata], list_data: Array) -> void:
	for element: Variant in list_data:
		if element is not Dictionary:
			continue
		var map_data := element as Dictionary
		map_list.append(MapMetadata.from_dict(map_data))
