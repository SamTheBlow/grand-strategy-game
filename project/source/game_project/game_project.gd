class_name GameProject
## Contains a game, its metadata, and more.
## Also contains useful functions.

var game := Game.new()
var textures := ProjectTextures.new(_absolute_file_path)
var metadata := ProjectMetadata.new()

var _absolute_file_path := StringRef.new()


func _init(absolute_file_path: String = "") -> void:
	_absolute_file_path.value = absolute_file_path


## Returns the absolute file path where this project is located.
func file_path() -> String:
	return _absolute_file_path.value


## Saves the project to its assigned file path.
func save() -> void:
	var project_save := ProjectSave.new()
	project_save.save_project(self)

	if project_save.error:
		push_warning(project_save.error_message)


## Updates this project's file path to use given path. Saves to the new path.
func save_as(absolute_file_path: String) -> void:
	_absolute_file_path.value = absolute_file_path
	save()


## In exported projects, file paths that start with "res://" are not valid.
func has_valid_file_path() -> bool:
	if (
			not OS.has_feature("editor")
			and file_path().begins_with("res://")
	):
		return false
	return FileAccess.file_exists(file_path())


## No effect if the project doesn't have a valid file path.
func show_in_file_manager() -> void:
	if has_valid_file_path():
		OS.shell_show_in_file_manager(file_path())
