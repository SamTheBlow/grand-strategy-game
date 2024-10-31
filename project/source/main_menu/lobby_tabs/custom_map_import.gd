class_name CustomMapImport
extends Node
## Imports custom maps from selected file/files/directory.


var map_menu_state: MapMenuState


func _add_map_from_path(path: String) -> void:
	var new_map: MapMetadata = MapMetadata.from_file_path(path)
	if new_map == null:
		return
	
	map_menu_state.add_custom_map(new_map)


## Recursively searches for JSON files in given directory path.
## When a JSON file is found, adds the map to the list.
func _scan_dir(dir: String) -> void:
	var dir_access := DirAccess.open(dir)
	
	for file in dir_access.get_files():
		if file.get_extension().to_lower() != "json":
			continue
		
		# Found a JSON file
		var map_file_path: String = dir.path_join(file)
		#print_debug("Found a map: ", map_file_path)
		_add_map_from_path(map_file_path)
	
	# Scan all the inner folders recursively
	for subdir in dir_access.get_directories():
		_scan_dir(dir.path_join(subdir))


func _on_import_dialog_file_selected(path: String) -> void:
	if map_menu_state == null:
		push_error("Map menu state is null.")
		return
	
	_add_map_from_path(path)


func _on_import_dialog_files_selected(paths: PackedStringArray) -> void:
	if map_menu_state == null:
		push_error("Map menu state is null.")
		return
	
	for path in paths:
		_add_map_from_path(path)


func _on_import_dialog_dir_selected(dir: String) -> void:
	if map_menu_state == null:
		push_error("Map menu state is null.")
		return
	
	_scan_dir(dir)
