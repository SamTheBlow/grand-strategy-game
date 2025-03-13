class_name GameImport
extends Node
## Imports game projects from selected file/files/directory.

var game_menu_state: GameSelectMenuState


func _add_project_from_path(path: String) -> void:
	var metadata: GameMetadata = GameMetadata.from_file_path(path)
	if metadata == null:
		return

	game_menu_state.add_imported_game(metadata)


## Recursively searches for JSON files in given directory path.
## When a JSON file is found, adds the game to the list.
func _scan_dir(dir: String) -> void:
	var dir_access := DirAccess.open(dir)

	for file in dir_access.get_files():
		if file.get_extension().to_lower() != "json":
			continue

		# Found a JSON file
		var project_file_path: String = dir.path_join(file)
		#print_debug("Found a project: ", project_file_path)
		_add_project_from_path(project_file_path)

	# Scan all the inner folders recursively
	for subdir in dir_access.get_directories():
		_scan_dir(dir.path_join(subdir))


func _on_import_dialog_file_selected(path: String) -> void:
	if game_menu_state == null:
		push_error("Game menu state is null.")
		return

	_add_project_from_path(path)


func _on_import_dialog_files_selected(paths: PackedStringArray) -> void:
	if game_menu_state == null:
		push_error("Game menu state is null.")
		return

	for path in paths:
		_add_project_from_path(path)


func _on_import_dialog_dir_selected(dir: String) -> void:
	if game_menu_state == null:
		push_error("Game menu state is null.")
		return

	_scan_dir(dir)
