class_name ProjectParsing
## Parses raw data from/to a [GameProject].

const METADATA_KEY: String = "meta"
const _VERSION_KEY: String = "version"
const _TEXTURES_KEY: String = "textures"

## The format version. If changes need to be made in the future
## to how the project is saved and loaded, this will allow us to tell
## if a file was made in an older or a newer version.
const _SAVE_DATA_VERSION: String = "1"


## The raw data must be a [Dictionary], and it must contain a valid version key.
## Everything else is optional and defaults to something.
##
## When parsing fails, the parse result contains a human-friendly error message.
static func parsed_from(raw_data: Variant, file_path: String) -> ParseResult:
	if raw_data is not Dictionary:
		return ResultError.new("Data is not a dictionary.")
	var raw_dict: Dictionary = raw_data

	# Check version
	if not raw_dict.has(_VERSION_KEY):
		return ResultError.new("Data doesn't have a \"version\" property.")
	if raw_dict[_VERSION_KEY] is not String:
		return ResultError.new(
				"Data is from an unsupported version."
				+ " The version property needs to be a string, but it isn't."
		)
	var version: String = raw_dict[_VERSION_KEY]
	if version != _SAVE_DATA_VERSION:
		return ResultError.new("Data is from an unsupported version.")

	return ResultSuccess.new(_game_project(raw_dict, file_path))


## Same thing as parsed_from(), but does a few more things.
## When applicable, generates the world, countries, etc.
## Overwrites the [GameRules] with given one.
## Populates the game (see [PopulatedSaveFile]).
static func generated_from(
		raw_data: Variant, meta_bundle: MetadataBundle, game_rules: GameRules
) -> ParseResult:
	# Load the project
	var parse_result: ParseResult = (
			parsed_from(raw_data, meta_bundle.project_absolute_path)
	)
	if parse_result.error:
		return parse_result
	var game_project: GameProject = parse_result.result_project

	# Overwrite the settings
	game_project.metadata.settings = meta_bundle.metadata.settings

	# Overwrite the rules
	game_project.game.rules = game_rules

	# Generate data, if applicable
	if game_project.metadata.project_name == "Random Grid World":
		var game_generation := RandomGridWorld.new()
		game_generation.load_settings(game_project.metadata.settings)
		if game_generation.error:
			return ResultError.new(game_generation.error_message)
		game_generation.apply(game_project.game)

	# Populate the game
	PopulatedSaveFile.apply(game_project.game)

	return ResultSuccess.new(game_project)


## Always succeeds.
static func to_raw_data(project: GameProject) -> Dictionary:
	var output: Dictionary = { _VERSION_KEY: _SAVE_DATA_VERSION }

	# Game
	var game_dict: Dictionary = GameParsing.to_raw_dict(project.game)
	if not game_dict.is_empty():
		output.merge(game_dict)

	# Textures
	var texture_data: Array = (
			ProjectTextureParsing.to_raw_array(project.textures, true)
	)
	if not texture_data.is_empty():
		output.merge({ _TEXTURES_KEY: texture_data })

	# Metadata
	var metadata_dict: Dictionary = project.metadata.to_raw_dict(true)
	if not metadata_dict.is_empty():
		output.merge({ METADATA_KEY: metadata_dict })

	return output


static func _game_project(
		raw_dict: Dictionary, project_absolute_path: String
) -> GameProject:
	var game_project := GameProject.new(project_absolute_path)

	# Load the textures
	game_project.textures = ProjectTextureParsing.from_raw_data(
			raw_dict.get(_TEXTURES_KEY), game_project._absolute_file_path
	)

	# Load the game
	game_project.game = (
			GameParsing.from_raw_dict(raw_dict, game_project.textures)
	)

	# Load the metadata
	game_project.metadata = MetadataParsing.from_raw_data(
			raw_dict.get(METADATA_KEY), game_project.file_path()
	)

	return game_project


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
