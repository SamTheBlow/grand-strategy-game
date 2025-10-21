class_name GameLoadGenerated
## Loads a [GameProject] using given [ProjectMetadata] and [GameRules].
## When applicable, generates the world, countries, etc.
## Then, populates the game (see [PopulatedSaveFile]).


# TODO this is mostly a copy/paste from [ProjectFromRaw] and also it's ugly.
static func result(
		metadata: ProjectMetadata, game_rules: GameRules
) -> ParseResult:
	# Load the project raw data from its file path
	var file_json := FileJSON.new()
	file_json.load_json(metadata.file_path)
	if file_json.error:
		return ResultError.new(file_json.error_message)
	if file_json.result is not Dictionary:
		return ResultError.new("Data is not a dictionary.")
	var raw_dict: Dictionary = file_json.result

	# Generate data, if applicable
	var game_generation: GameGeneration = null
	if metadata.project_name == "Random Grid World":
		game_generation = RandomGridWorld.new()

	if game_generation != null:
		game_generation.load_settings(metadata.settings)
		if game_generation.error:
			return ResultError.new(game_generation.error_message)
		game_generation.apply(raw_dict)

	var game_project := GameProject.new()

	# Load the textures
	game_project.textures = ProjectTextureParsing.textures_from_raw_data(
			raw_dict.get(ProjectFromRaw.TEXTURES_KEY)
	)

	# Load the game & game settings
	game_project.game = GameParsing.game_from_raw_dict(
			raw_dict, metadata.file_path, game_project.settings
	)

	# Load the metadata
	game_project.metadata = metadata
	game_project.settings.custom_settings = game_project.metadata.settings

	game_project.connect_signals()

	# Overwrite the rules
	game_project.game.rules = game_rules

	# Populate the game
	PopulatedSaveFile.apply(game_project.game)

	return ResultSuccess.new(game_project)


@abstract class ParseResult:
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
