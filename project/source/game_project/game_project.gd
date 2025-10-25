class_name GameProject
## Contains a game, its metadata, and more.
## Also contains useful functions.

var game := Game.new()
var textures := ProjectTextures.new()
var settings := GameSettings.new()
var metadata := ProjectMetadata.new()


# TODO bad code.
## Please call this right after you load the project.
func connect_signals() -> void:
	settings.custom_world_limits_enabled.value_changed.connect(
		func(item: ItemBool) -> void:
			if item.value:
				settings.world_limits.enable_custom_limits()
			else:
				settings.world_limits.disable_custom_limits(game.world)
	)


## Saves the project to its assigned file path.
func save() -> void:
	var project_save := ProjectSave.new()
	project_save.save_project(self)

	if project_save.error:
		push_warning(project_save.error_message)


## Updates this project's file path to use given path. Saves to the new path.
func save_as(file_path: String) -> void:
	metadata.file_path = file_path
	save()


## In exported projects, file paths that start with "res://" are not valid.
func has_valid_file_path() -> bool:
	if (
			not OS.has_feature("editor")
			and metadata.file_path.begins_with("res://")
	):
		return false
	return FileAccess.file_exists(metadata.file_path)


## No effect if the project doesn't have a valid file path.
func show_in_file_manager() -> void:
	if has_valid_file_path():
		OS.shell_show_in_file_manager(
				ProjectSettings.globalize_path(metadata.file_path)
		)
