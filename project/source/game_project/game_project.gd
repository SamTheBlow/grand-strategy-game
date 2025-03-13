class_name GameProject
## Contains a game, its settings, and its metadata.
## Also contains useful functions.

const _DEFAULT_PROJECT_NAME: String = "(Unnamed project)"

var game: Game
# TODO implement some new GameSettings object to put here
var metadata: GameMetadata


func _init() -> void:
	game = Game.new()
	metadata = GameMetadata.new()
	metadata.project_name = _DEFAULT_PROJECT_NAME


## Saves the project to its assigned file path.
func save() -> void:
	var game_save := GameSave.new()
	game_save.save_game(game, metadata.file_path)
	
	if game_save.error:
		push_warning(game_save.error_message)


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
