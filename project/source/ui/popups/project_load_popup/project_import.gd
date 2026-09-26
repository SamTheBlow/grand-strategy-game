class_name ProjectImport
extends Node
## Loads [ProjectMetadata] from some file/files/directory.

signal saved_game_imported(metadata_bundle: MetadataBundle)
signal project_imported(metadata_bundle: MetadataBundle)

@export var _imported_projects: ImportedProjects


func _ready() -> void:
	# We need to wait for other nodes to be ready
	await get_tree().process_frame

	_reimport_previously_imported_projects()
	_import_saved_games()


func _reimport_previously_imported_projects() -> void:
	for file_path in _imported_projects.file_paths.duplicate() as Array[String]:
		var parse_result: MetadataBundle.ParseResult = (
				MetadataBundle.from_path(file_path)
		)
		if parse_result.error:
			_imported_projects.file_paths.erase(file_path)
		else:
			project_imported.emit(parse_result.result)


func _import_saved_games() -> void:
	const USER_DIR: String = "user://"

	var dir_access: DirAccess = DirAccess.open(USER_DIR)
	if dir_access == null:
		return

	var user_absolute_path: String = ProjectSettings.globalize_path(USER_DIR)
	for file_path in dir_access.get_files():
		var absolute_file_path: String = user_absolute_path.path_join(file_path)

		if not ProjectParsing.is_project(absolute_file_path):
			continue

		var parse_result := MetadataBundle.from_path(absolute_file_path)
		if parse_result.error:
			continue

		saved_game_imported.emit(parse_result.result)


func _import_from_path(file_path: String) -> void:
	file_path = ProjectSettings.globalize_path(file_path)

	if (
			_is_already_imported(file_path)
			or not ProjectParsing.is_project(file_path)
	):
		return

	var parse_result := MetadataBundle.from_path(file_path)
	if parse_result.error:
		return

	_imported_projects.file_paths.append(file_path)
	project_imported.emit(parse_result.result)


func _is_already_imported(candidate_path: String) -> bool:
	var dir_access: DirAccess = DirAccess.open(candidate_path.get_base_dir())
	if dir_access == null:
		return false

	for existing_path in _imported_projects.file_paths:
		if dir_access.is_equivalent(existing_path, candidate_path):
			return true

	return false


## Recursively searches for project files in given directory path.
## When a project file is found, imports that file.
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
