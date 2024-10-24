extends MapListNode
## The map list for custom maps.


## Recursively searches for JSON files in given directory path.
## When a JSON file is found, adds the map to the list.
func _scan_dir(dir: String) -> void:
	var dir_access := DirAccess.open(dir)
	
	for file in dir_access.get_files():
		if file.get_extension().to_lower() == "json":
			# Found a JSON file
			#print_debug("Found a map: ", dir.path_join(file))
			add_map(dir.path_join(file))
	
	# Scan all the inner folders recursively
	for subdir in dir_access.get_directories():
		_scan_dir(dir.path_join(subdir))


func _on_import_dialog_file_selected(path: String) -> void:
	add_map(path)


func _on_import_dialog_files_selected(paths: PackedStringArray) -> void:
	add_maps(paths)


func _on_import_dialog_dir_selected(dir: String) -> void:
	_scan_dir(dir)
