class_name ProjectFromRaw
## Converts raw data into a [GameProject].
##
## See also: [ProjectToRawDict]


static func parsed_from(raw_data: Variant, file_path: String) -> ParseResult:
	# Load the game
	var game_from_raw: GameFromRaw.ParseResult = (
			GameFromRaw.parsed_from(raw_data)
	)
	if game_from_raw.error:
		return ResultError.new(game_from_raw.error_message)

	# Load the metadata
	var metadata: GameMetadata = GameMetadata.from_raw(raw_data, file_path)

	var game_project := GameProject.new()
	game_project.game = game_from_raw.result_game
	game_project.settings.custom_settings = metadata.settings
	game_project.metadata = metadata
	return ResultSuccess.new(game_project)


class ParseResult:
	var error: bool
	var error_message: String
	var result_project: GameProject


class ResultError extends ParseResult:
	func _init(error_message_: String) -> void:
		error = true
		error_message = error_message_


class ResultSuccess extends ParseResult:
	func _init(game_project: GameProject) -> void:
		result_project = game_project
