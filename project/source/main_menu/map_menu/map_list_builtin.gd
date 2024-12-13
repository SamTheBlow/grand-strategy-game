class_name MapListBuiltin
extends MapListNode
## Specifically the list of built-in maps.

## The list of all the built-in maps, as file paths.
@export var builtin_maps: Array[String] = []


func add_map(map_metadata: MapMetadata, map_id: int) -> void:
	super(map_metadata, map_id)

	# Hide the file path for built-in maps
	if _list.size() > 0:
		_list.back().is_file_path_visible = false
