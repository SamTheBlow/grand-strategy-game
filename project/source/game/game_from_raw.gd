class_name GameFromRaw
## Converts raw data into a [Game].
##
## The raw data must be a [Dictionary], and it must contain a valid version key.
## Everything else is optional and defaults to something.
##
## When parsing fails, the parse result contains a human-friendly error message.
##
## See also: [GameToRawDict]

const VERSION_KEY: String = "version"
const RULES_KEY: String = "rules"
const RNG_KEY: String = "rng"
const TURN_KEY: String = "turn"
const WORLD_KEY: String = "world"
const COUNTRIES_KEY: String = "countries"
const PLAYERS_KEY: String = "players"
const BACKGROUND_COLOR_KEY: String = "background_color"

## The format version. If changes need to be made in the future
## to how the game is saved and loaded, this will allow us to tell
## if a file was made in an older or a newer version.
const SAVE_DATA_VERSION: String = "1"


static func parsed_from(raw_data: Variant) -> ParseResult:
	if raw_data is not Dictionary:
		return ResultError.new("Data is not a dictionary.")
	var raw_dict: Dictionary = raw_data

	# Check version
	if not raw_dict.has(VERSION_KEY):
		return ResultError.new("Data doesn't have a \"version\" property.")
	if raw_dict[VERSION_KEY] is not String:
		return ResultError.new(
				"Data is an unsupported version."
				+ " The version property needs to be a string, but it isn't."
		)
	var version: String = raw_dict[VERSION_KEY]
	if version != SAVE_DATA_VERSION:
		return ResultError.new("Data is an unsupported version.")

	# Loading begins!
	var game := Game.new()
	var game_settings := GameSettings.new()

	# Rules
	game.rules = RulesFromRaw.parsed_from(raw_dict.get(RULES_KEY))

	# RNG
	game.rng = RNGFromRaw.parsed_from(raw_dict.get(RNG_KEY))

	# Turn
	game.turn = TurnFromRaw.parsed_from(raw_dict.get(TURN_KEY)).game_turn(game)

	# Countries
	var country_data: Variant = raw_dict.get(COUNTRIES_KEY)
	game.countries = CountriesFromRaw.parsed_from(country_data)

	# Relationships
	CountryRelationshipsFromRaw.parse_using(country_data, game)

	# Players
	GamePlayersFromRaw.parse_using(raw_dict.get(PLAYERS_KEY), game)

	# Notifications
	CountryNotificationsFromRaw.parse_using(country_data, game)

	# World
	WorldFromRaw.parse_using(raw_dict.get(WORLD_KEY), game, game_settings)

	# [AutoArrow]s
	AutoArrowsFromRaw.parse_using(country_data, game)

	# Background color
	if raw_dict.has(BACKGROUND_COLOR_KEY):
		var background_color: Color = ParseUtils.color_from_raw(
				raw_dict.get(BACKGROUND_COLOR_KEY),
				GameSettings.DEFAULT_BACKGROUND_COLOR
		)
		game_settings.background_color.value = background_color

	return ResultSuccess.new(game, game_settings)


class ParseResult:
	var error: bool
	var error_message: String
	var result_game: Game
	var result_settings: GameSettings


class ResultError extends ParseResult:
	func _init(error_message_: String) -> void:
		error = true
		error_message = error_message_


class ResultSuccess extends ParseResult:
	func _init(game: Game, game_settings: GameSettings) -> void:
		result_game = game
		result_settings = game_settings
