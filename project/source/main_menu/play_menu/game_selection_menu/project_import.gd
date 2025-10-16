class_name ProjectImport
extends Node
## Loads [ProjectMetadata] from some file/files/directory.

## Emitted whenever a project is successfully imported.
signal project_imported(project_metadata: ProjectMetadata)


func _import_from_path(path: String) -> void:
	var metadata: ProjectMetadata = ProjectMetadata.from_file_path(path)
	if metadata != null:
		project_imported.emit(metadata)


## Recursively searches for JSON files in given directory path.
## When a JSON file is found, imports that file.
func _scan_dir(dir: String) -> void:
	var dir_access := DirAccess.open(dir)

	for file in dir_access.get_files():
		if file.get_extension().to_lower() == "json":
			_import_from_path(dir.path_join(file))

	# Scan all the inner folders recursively
	for subdir in dir_access.get_directories():
		_scan_dir(dir.path_join(subdir))


func _on_import_dialog_file_selected(path: String) -> void:
	_import_from_path(path)


func _on_import_dialog_files_selected(paths: PackedStringArray) -> void:
	for path in paths:
		_import_from_path(path)


func _on_import_dialog_dir_selected(dir: String) -> void:
	_scan_dir(dir)
