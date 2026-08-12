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


## Returns true if given file is (most likely) a project.
static func is_project(absolute_file_path: String) -> bool:
	var file_json := FileJSON.new()
	file_json.load_json(absolute_file_path)
	if file_json.error:
		return false
	var raw_data: Variant = file_json.result

	if raw_data is not Dictionary:
		return false
	var raw_dict := raw_data as Dictionary

	# Check version
	if not raw_dict.has(_VERSION_KEY):
		return false
	if raw_dict[_VERSION_KEY] is not String:
		return false
	var version: String = raw_dict[_VERSION_KEY]
	if version != _SAVE_DATA_VERSION:
		return false

	return true


static func _game_project(
		raw_dict: Dictionary, file_path: String
) -> GameProject:
	var game_project := GameProject.new(
			ProjectSettings.globalize_path(file_path)
	)

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
