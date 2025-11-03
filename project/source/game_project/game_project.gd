class_name GameProject
## Contains a game, its metadata, and more.
## Also contains useful functions.

var game := Game.new()
var metadata := ProjectMetadata.new()
var textures := ProjectTextures.new(metadata.project_absolute_path)


## Saves the project to its assigned file path.
func save() -> void:
	var project_save := ProjectSave.new()
	project_save.save_project(self)

	if project_save.error:
		push_warning(project_save.error_message)


## Updates this project's file path to use given path. Saves to the new path.
func save_as(file_path: String) -> void:
	metadata.project_absolute_path.value = file_path
	save()


## In exported projects, file paths that start with "res://" are not valid.
func has_valid_file_path() -> bool:
	if (
			not OS.has_feature("editor")
			and metadata.project_absolute_path.value.begins_with("res://")
	):
		return false
	return FileAccess.file_exists(metadata.project_absolute_path.value)


## No effect if the project doesn't have a valid file path.
func show_in_file_manager() -> void:
	if has_valid_file_path():
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path(
				metadata.project_absolute_path.value
		))
