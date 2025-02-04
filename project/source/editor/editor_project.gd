class_name EditorProject

const DEFAULT_PROJECT_NAME: String = "(Unnamed project)"

## Fake variable. Gets and sets the name that's stored in the metadata.
var name: String:
	get:
		return _meta.map_name
	set(value):
		_meta.map_name = value

var _game: Game
var _meta: MapMetadata


func _init(game: Game = null, metadata: MapMetadata = null) -> void:
	if game == null or metadata == null:
		_game = Game.new()
		_meta = MapMetadata.new()
		_meta.map_name = DEFAULT_PROJECT_NAME
		return

	_game = game
	_meta = metadata


## Saves the project to its assigned file path.
func save() -> void:
	var game_save := GameSave.new()
	game_save.save_game(_game, _meta.file_path)
	
	if game_save.error:
		push_warning(game_save.error_message)


## Updates this project's file path to use given path. Saves to the new path.
func save_as(file_path: String) -> void:
	_meta.file_path = file_path
	save()


func has_valid_file_path() -> bool:
	return FileAccess.file_exists(_meta.file_path)


## No effect if the project doesn't have a valid file path.
func show_in_file_manager() -> void:
	if has_valid_file_path():
		OS.shell_show_in_file_manager(_meta.file_path)
