class_name ProjectFromPath
## Loads a [GameProject] from given file path.


static func loaded_from(file_path: String) -> ParseResult:
	# Load the file
	var file_json := FileJSON.new()
	file_json.load_json(file_path)
	if file_json.error:
		return ResultError.new(file_json.error_message)

	if file_json.result is not Dictionary:
		return ResultError.new("JSON data is not a dictionary.")

	# Load the game using the file data
	var game_from_raw: GameFromRaw.ParseResult = (
			GameFromRaw.parsed_from(file_json.result)
	)
	if game_from_raw.error:
		return ResultError.new(game_from_raw.error_message)

	# Load the metadata
	var metadata: GameMetadata = GameMetadata.from_file_path(file_path)
	if metadata == null:
		metadata = GameMetadata.new()
		metadata.file_path = file_path

	return ResultSuccess.new(game_from_raw.result_game, metadata)


class ParseResult:
	var error: bool
	var error_message: String
	var result_project: GameProject


class ResultError extends ParseResult:
	func _init(error_message_: String) -> void:
		error = true
		error_message = error_message_


class ResultSuccess extends ParseResult:
	func _init(game: Game, metadata: GameMetadata) -> void:
		result_project = GameProject.new()
		result_project.game = game
		result_project.metadata = metadata
