class_name MapListBuiltin
extends MapListNode
## Specifically the list of built-in maps.


## The list of all the built-in maps, as file paths.
@export var builtin_maps: Array[String] = []


func _ready() -> void:
	super()
	for file_path in builtin_maps:
		add_map(file_path)


func add_map(file_path: String) -> void:
	super(file_path)
	
	# Hide the file path for built-in maps
	if _list.size() > 0:
		_list.back().is_file_path_visible = false
