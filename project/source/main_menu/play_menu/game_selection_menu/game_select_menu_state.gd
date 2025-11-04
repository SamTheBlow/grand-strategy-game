class_name GameSelectMenuState
## Data structure. Contains all the data related to the game selection menu.

## This is not emitted when updating the entire state at once.
signal selected_game_changed()
## This is not emitted when updating the entire state at once.
signal builtin_game_added(meta_bundle: MetadataBundle)
## This is not emitted when updating the entire state at once.
signal imported_game_added(meta_bundle: MetadataBundle)
## Emitted when information inside a game's metadata is changed.
## This is not emitted when updating the entire state at once.
signal metadata_changed(game_id: int, metadata: ProjectMetadata)
## Emitted after the entire state is updated.
signal state_changed(this: GameSelectMenuState)

const _SELECTED_GAME_KEY: String = "selected_game"
const _BUILTIN_GAMES_KEY: String = "builtin_games"
const _IMPORTED_GAMES_KEY: String = "custom_games"

var _selected_game_id: int = -1
var _builtin_games: Array[MetadataBundle] = []
var _imported_games: Array[MetadataBundle] = []


## Returns null if there is no game with given id.
func game_with_id(game_id: int) -> MetadataBundle:
	var counter: int = 0
	for game in _builtin_games:
		if counter == game_id:
			return game
		counter += 1
	for game in _imported_games:
		if counter == game_id:
			return game
		counter += 1
	return null


func selected_game_id() -> int:
	return _selected_game_id


func set_selected_game_id(game_id: int) -> void:
	_selected_game_id = game_id
	selected_game_changed.emit()


## Returns true if the selected game id
## is a valid index in the built-in games array.
func is_selected_game_builtin() -> bool:
	return _selected_game_id >= 0 and _selected_game_id < _builtin_games.size()


func builtin_games() -> Array[MetadataBundle]:
	return _builtin_games.duplicate()


func add_builtin_game(meta_bundle: MetadataBundle) -> void:
	meta_bundle.metadata.setting_changed.connect(_on_metadata_changed)
	_builtin_games.append(meta_bundle)
	builtin_game_added.emit(meta_bundle)


func imported_games() -> Array[MetadataBundle]:
	return _imported_games.duplicate()


func add_imported_game(meta_bundle: MetadataBundle) -> void:
	meta_bundle.metadata.setting_changed.connect(_on_metadata_changed)
	_imported_games.append(meta_bundle)
	imported_game_added.emit(meta_bundle)


func number_of_games() -> int:
	return _builtin_games.size() + _imported_games.size()


## Returns the entire state as a Dictionary. Useful for networking.
## If include_file_paths is set to false, file paths will not be included.
func get_raw_state(include_file_paths: bool = true) -> Dictionary:
	var _raw_builtin_games: Array = []
	for meta_bundle in _builtin_games:
		_raw_builtin_games.append(meta_bundle.to_raw_data(include_file_paths))

	var _raw_imported_games: Array = []
	for meta_bundle in _imported_games:
		_raw_imported_games.append(meta_bundle.to_raw_data(include_file_paths))

	return {
		_SELECTED_GAME_KEY: _selected_game_id,
		_BUILTIN_GAMES_KEY: _raw_builtin_games,
		_IMPORTED_GAMES_KEY: _raw_imported_games,
	}


## Updates the entire state to match given Dictionary. Useful for networking.
func set_raw_state(data: Dictionary) -> void:
	_builtin_games = []
	if ParseUtils.dictionary_has_array(data, _BUILTIN_GAMES_KEY):
		var game_list: Array = data[_BUILTIN_GAMES_KEY]
		_populate_game_list(_builtin_games, game_list)

	_imported_games = []
	if ParseUtils.dictionary_has_array(data, _IMPORTED_GAMES_KEY):
		var game_list: Array = data[_IMPORTED_GAMES_KEY]
		_populate_game_list(_imported_games, game_list)

	_selected_game_id = -1
	if ParseUtils.dictionary_has_number(data, _SELECTED_GAME_KEY):
		_selected_game_id = ParseUtils.dictionary_int(data, _SELECTED_GAME_KEY)

	state_changed.emit(self)


func _populate_game_list(
		game_list: Array[MetadataBundle], list_data: Array
) -> void:
	for bundle_raw_data: Variant in list_data:
		var meta_bundle: MetadataBundle = (
				MetadataBundle.from_raw_data(bundle_raw_data)
		)
		meta_bundle.metadata.setting_changed.connect(_on_metadata_changed)
		game_list.append(meta_bundle)


## Returns -1 if this metadata is not on one of the lists.
func _id_of(metadata: ProjectMetadata) -> int:
	var output: int = 0
	for meta_bundle in _builtin_games:
		if metadata == meta_bundle.metadata:
			return output
		output += 1
	for meta_bundle in _imported_games:
		if metadata == meta_bundle.metadata:
			return output
		output += 1
	return -1


func _on_metadata_changed(metadata: ProjectMetadata) -> void:
	metadata_changed.emit(_id_of(metadata), metadata)
