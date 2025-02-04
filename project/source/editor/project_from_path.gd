class_name ProjectFromPath
## Loads a project from given file path. This includes a game and its metadata.


static func loaded_from(file_path: String) -> ProjectParseResult:
	# Load the file
	var file_json := FileJSON.new()
	file_json.load_json(file_path)
	if file_json.error:
		return ResultError.new(file_json.error_message)

	if file_json.result is not Dictionary:
		return ResultError.new("JSON data is not a dictionary.")

	# Load the game using the file data
	var game_from_raw := GameFromRawDict.new()
	game_from_raw.load_game(file_json.result)
	if game_from_raw.error:
		return ResultError.new(game_from_raw.error_message)

	# Load the metadata using the file data
	var metadata := MapMetadata.from_dict(file_json.result)

	return ResultSuccess.new(game_from_raw.result, metadata)


class ProjectParseResult:
	var error: bool
	var error_message: String
	var result_project: EditorProject


class ResultError extends ProjectParseResult:
	func _init(error_message_: String) -> void:
		error = true
		error_message = error_message_


class ResultSuccess extends ProjectParseResult:
	func _init(game: Game, metadata: MapMetadata) -> void:
		result_project = EditorProject.new(game, metadata)
