class_name EditorProject

const DEFAULT_PROJECT_NAME: String = "(Unnamed project)"

## Fake variable. Gets and sets the name that's stored in the metadata.
var name: String:
	get:
		return _meta.map_name
	set(value):
		_meta.map_name = value

var game: Game
var _meta: MapMetadata


func _init(game_: Game = null, metadata: MapMetadata = null) -> void:
	if game_ == null or metadata == null:
		game = Game.new()
		_meta = MapMetadata.new()
		_meta.map_name = DEFAULT_PROJECT_NAME
		return

	game = game_
	_meta = metadata


## Saves the project to its assigned file path.
func save() -> void:
	var game_save := GameSave.new()
	game_save.save_game(game, _meta.file_path)
	
	if game_save.error:
		push_warning(game_save.error_message)


## Updates this project's file path to use given path. Saves to the new path.
func save_as(file_path: String) -> void:
	_meta.file_path = file_path
	save()


## In exported projects, file paths that start with "res://" are not valid.
func has_valid_file_path() -> bool:
	if (not OS.has_feature("editor")) and _meta.file_path.begins_with("res://"):
		return false
	return FileAccess.file_exists(_meta.file_path)


## No effect if the project doesn't have a valid file path.
func show_in_file_manager() -> void:
	if has_valid_file_path():
		OS.shell_show_in_file_manager(
				ProjectSettings.globalize_path(_meta.file_path)
		)
