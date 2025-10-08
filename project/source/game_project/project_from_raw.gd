class_name ProjectFromRaw
## Converts raw data into a [GameProject].
##
## The raw data must be a [Dictionary], and it must contain a valid version key.
## Everything else is optional and defaults to something.
##
## When parsing fails, the parse result contains a human-friendly error message.
##
## See also: [ProjectToRawDict]

const VERSION_KEY: String = "version"
const TEXTURES_KEY: String = "textures"

## The format version. If changes need to be made in the future
## to how the project is saved and loaded, this will allow us to tell
## if a file was made in an older or a newer version.
const SAVE_DATA_VERSION: String = "1"


static func parsed_from(raw_data: Variant, file_path: String) -> ParseResult:
	if raw_data is not Dictionary:
		return ResultError.new("Data is not a dictionary.")
	var raw_dict: Dictionary = raw_data

	# Check version
	if not raw_dict.has(VERSION_KEY):
		return ResultError.new("Data doesn't have a \"version\" property.")
	if raw_dict[VERSION_KEY] is not String:
		return ResultError.new(
				"Data is from an unsupported version."
				+ " The version property needs to be a string, but it isn't."
		)
	var version: String = raw_dict[VERSION_KEY]
	if version != SAVE_DATA_VERSION:
		return ResultError.new("Data is from an unsupported version.")

	var game_project := GameProject.new()

	# Load the game & game settings
	game_project.game = (
			GameFromRaw.parsed_from(raw_dict, file_path, game_project.settings)
	)

	# Load the textures
	game_project.textures = ProjectTextureParsing.textures_from_raw_data(
			raw_dict.get(TEXTURES_KEY)
	)

	# Load the metadata
	game_project.metadata = GameMetadata.from_raw(raw_data, file_path)
	game_project.settings.custom_settings = game_project.metadata.settings

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
