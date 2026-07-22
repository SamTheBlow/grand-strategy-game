class_name GameParsing
## Parses raw data from/to a [Game].

const _STATUS_KEY: String = "status"
const _RULES_KEY: String = "rules"
const _RNG_KEY: String = "rng"
const _TURN_KEY: String = "turn"
const _WORLD_KEY: String = "world"
const _COUNTRIES_KEY: String = "countries"
const _PLAYERS_KEY: String = "players"


## Always succeeds.
static func from_raw_dict(
		raw_dict: Dictionary, project_textures: ProjectTextures
) -> Game:
	return GameFromRawData.new(raw_dict, project_textures)


static func to_raw_dict(game: Game) -> Dictionary:
	var output: Dictionary = {}

	# Status
	var status_data: Array = GameStateParsing.to_raw_data(game.state())
	if not status_data.is_empty():
		output.merge({ _STATUS_KEY: status_data[0] })

	# Rules
	var rules_data: Dictionary = RuleParsing.to_raw_dict(game.rules)
	if not rules_data.is_empty():
		output.merge({ _RULES_KEY: rules_data })

	# RNG
	output.merge({ _RNG_KEY: RNGParsing.to_raw_data(game.rng) })

	# Players
	var players_data: Array = GamePlayerParsing.to_raw_array(game.game_players)
	if not players_data.is_empty():
		output.merge({ _PLAYERS_KEY: players_data })

	# Countries
	var countries_data: Array = (
			CountryParsing.to_raw_array(game.countries.list())
	)
	if not countries_data.is_empty():
		output.merge({ _COUNTRIES_KEY: countries_data })

	# World
	var world_data: Dictionary = WorldParsing.to_raw_dict(game.world)
	if not world_data.is_empty():
		output.merge({ _WORLD_KEY: world_data })

	# Turn
	var turn_data: Dictionary = TurnParsing.to_raw_dict(game.turn)
	if not turn_data.is_empty():
		output.merge({ _TURN_KEY: turn_data })

	return output


class GameFromRawData extends Game:
	func _init(raw_dict: Dictionary, project_textures: ProjectTextures) -> void:
		# Rules
		rules = RuleParsing.from_raw_data(raw_dict.get(_RULES_KEY))

		# RNG
		rng = RNGParsing.from_raw_data(raw_dict.get(_RNG_KEY))

		# Turn
		turn = (
				TurnParsing.from_raw_data(raw_dict.get(_TURN_KEY))
				.game_turn(self)
		)

		# Countries
		var country_data: Variant = raw_dict.get(_COUNTRIES_KEY)
		countries = CountryParsing.from_raw_data(country_data)

		# Relationships
		DiplomacyRelationshipParsing.load_from_country_data(country_data, self)

		# Players
		GamePlayerParsing.load_from_raw_data(raw_dict.get(_PLAYERS_KEY), self)

		# Notifications
		GameNotificationParsing.load_from_country_data(country_data, self)

		# World
		WorldParsing.load_from_raw_data(
				raw_dict.get(_WORLD_KEY), self, project_textures
		)

		super()

		# Status
		var status: Game.GameState = (
				GameStateParsing.from_raw_data(raw_dict.get(_STATUS_KEY))
		)
		if status != Game.GameState.SETUP:
			end_setup()
			if status == Game.GameState.GAMEOVER:
				end_game()


class GameStateParsing:
	const _STATE_SETUP: String = "setup"
	const _STATE_ONGOING: String = "ongoing"
	const _STATE_GAMEOVER: String = "gameover"
	const _DEFAULT_STATE: Game.GameState = Game.GameState.SETUP

	static func from_raw_data(raw_data: Variant) -> Game.GameState:
		match raw_data:
			null:
				return _DEFAULT_STATE
			_STATE_SETUP:
				return Game.GameState.SETUP
			_STATE_ONGOING:
				return Game.GameState.ONGOING
			_STATE_GAMEOVER:
				return Game.GameState.GAMEOVER
			_:
				push_error("Unrecognized game state!")
				return _DEFAULT_STATE

	# Returns an array with one element of type Variant.
	# Or, returns an empty array if it's the default value.
	static func to_raw_data(game_state: Game.GameState) -> Array:
		if game_state == _DEFAULT_STATE:
			return []

		match game_state:
			Game.GameState.SETUP:
				return [_STATE_SETUP]
			Game.GameState.ONGOING:
				return [_STATE_ONGOING]
			Game.GameState.GAMEOVER:
				return [_STATE_GAMEOVER]
			_:
				push_error("Unrecognized game state!")
				return []
