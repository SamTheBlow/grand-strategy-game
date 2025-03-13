class_name GameSelectMenuState
## Data structure. Contains all the data related to the game selection menu.

## This is not emitted when updating the entire state at once.
signal selected_game_changed()
## This is not emitted when updating the entire state at once.
signal builtin_game_added(metadata: GameMetadata)
## This is not emitted when updating the entire state at once.
signal imported_game_added(metadata: GameMetadata)
## Emitted when information inside a game's metadata is changed.
## This is not emitted when updating the entire state at once.
signal metadata_changed(game_id: int, metadata: GameMetadata)
## Emitted after the entire state is updated.
signal state_changed(this: GameSelectMenuState)

# TODO 4.2 backwards compatibility: these will change respectively into
# "selected_game_id", "builtin_game_list", and "imported_game_list".
const KEY_SELECTED_GAME: String = "selected_map_id"
const KEY_BUILTIN_GAME_LIST: String = "builtin_map_list"
const KEY_IMPORTED_GAME_LIST: String = "custom_map_list"

var _selected_game_id: int = -1
var _builtin_games: Array[GameMetadata] = []
var _imported_games: Array[GameMetadata] = []


## Returns null if there is no game with given id.
func game_with_id(game_id: int) -> GameMetadata:
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


func builtin_games() -> Array[GameMetadata]:
	return _builtin_games.duplicate()


func add_builtin_game(metadata: GameMetadata) -> void:
	metadata.setting_changed.connect(_on_metadata_changed)
	_builtin_games.append(metadata)
	builtin_game_added.emit(metadata)


func imported_games() -> Array[GameMetadata]:
	return _imported_games.duplicate()


func add_imported_game(metadata: GameMetadata) -> void:
	metadata.setting_changed.connect(_on_metadata_changed)
	_imported_games.append(metadata)
	imported_game_added.emit(metadata)


func number_of_games() -> int:
	return _builtin_games.size() + _imported_games.size()


## Returns the entire state as a Dictionary. Useful for networking.
## If include_file_paths is set to false, file paths will not be included.
func get_raw_state(include_file_paths: bool = true) -> Dictionary:
	var _raw_builtin_games: Array = []
	for builtin_game in _builtin_games:
		_raw_builtin_games.append(builtin_game.to_dict(include_file_paths))

	var _raw_imported_games: Array = []
	for imported_game in _imported_games:
		_raw_imported_games.append(imported_game.to_dict(include_file_paths))

	return {
		KEY_SELECTED_GAME: _selected_game_id,
		KEY_BUILTIN_GAME_LIST: _raw_builtin_games,
		KEY_IMPORTED_GAME_LIST: _raw_imported_games,
	}


## Updates the entire state to match given Dictionary. Useful for networking.
func set_raw_state(data: Dictionary) -> void:
	_builtin_games = []
	if ParseUtils.dictionary_has_array(data, KEY_BUILTIN_GAME_LIST):
		var game_list: Array = data[KEY_BUILTIN_GAME_LIST]
		_populate_game_list(_builtin_games, game_list)

	_imported_games = []
	if ParseUtils.dictionary_has_array(data, KEY_IMPORTED_GAME_LIST):
		var game_list: Array = data[KEY_IMPORTED_GAME_LIST]
		_populate_game_list(_imported_games, game_list)

	_selected_game_id = -1
	if ParseUtils.dictionary_has_number(data, KEY_SELECTED_GAME):
		_selected_game_id = ParseUtils.dictionary_int(data, KEY_SELECTED_GAME)

	state_changed.emit(self)


func _populate_game_list(
		game_list: Array[GameMetadata], list_data: Array
) -> void:
	for element: Variant in list_data:
		if element is not Dictionary:
			continue
		var game_data: Dictionary = element

		var metadata: GameMetadata = GameMetadata.from_dict(game_data)
		metadata.setting_changed.connect(_on_metadata_changed)
		game_list.append(metadata)


## Returns -1 if this metadata is not on one of the lists.
func _id_of(metadata: GameMetadata) -> int:
	var output: int = 0
	for game in _builtin_games:
		if metadata == game:
			return output
		output += 1
	for game in _imported_games:
		if metadata == game:
			return output
		output += 1
	return -1


func _on_metadata_changed(metadata: GameMetadata) -> void:
	metadata_changed.emit(_id_of(metadata), metadata)
