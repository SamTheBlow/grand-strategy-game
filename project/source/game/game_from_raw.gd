class_name GameFromRaw
## Converts raw data into a [Game].
##
## This operation always succeeds.
##
## See also: [GameToRawDict]

const RULES_KEY: String = "rules"
const RNG_KEY: String = "rng"
const TURN_KEY: String = "turn"
const WORLD_KEY: String = "world"
const COUNTRIES_KEY: String = "countries"
const PLAYERS_KEY: String = "players"
const BACKGROUND_COLOR_KEY: String = "background_color"


static func parsed_from(
		raw_dict: Dictionary,
		project_file_path: String,
		game_settings: GameSettings
) -> Game:
	var game := Game.new()

	# Rules
	game.rules = RulesFromRaw.parsed_from(raw_dict.get(RULES_KEY))

	# RNG
	game.rng = RNGFromRaw.parsed_from(raw_dict.get(RNG_KEY))

	# Turn
	game.turn = TurnFromRaw.parsed_from(raw_dict.get(TURN_KEY)).game_turn(game)

	# Countries
	var country_data: Variant = raw_dict.get(COUNTRIES_KEY)
	game.countries = Countries.from_raw_data(country_data)

	# Relationships
	CountryRelationshipsFromRaw.parse_using(country_data, game)

	# Players
	GamePlayersFromRaw.parse_using(raw_dict.get(PLAYERS_KEY), game)

	# Notifications
	CountryNotificationsFromRaw.parse_using(country_data, game)

	# World
	WorldFromRaw.parse_using(
			raw_dict.get(WORLD_KEY), game, game_settings, project_file_path
	)

	# [AutoArrow]s
	AutoArrowsFromRaw.parse_using(country_data, game)

	# Background color
	if raw_dict.has(BACKGROUND_COLOR_KEY):
		var background_color: Color = ParseUtils.color_from_raw(
				raw_dict.get(BACKGROUND_COLOR_KEY),
				GameSettings.DEFAULT_BACKGROUND_COLOR
		)
		game_settings.background_color.value = background_color

	return game
