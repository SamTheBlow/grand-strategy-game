class_name GameParsing
## Parses raw data from/to a [Game].

const _STATUS_KEY: String = "status"
const _RNG_KEY: String = "rng"
const _TURN_KEY: String = "turn"
const _WORLD_KEY: String = "world"
const _COUNTRIES_KEY: String = "countries"
const _PLAYERS_KEY: String = "players"
const _COMPONENTS_KEY: String = "components"


## Always succeeds.
static func from_raw_dict(
		raw_dict: Dictionary, project_textures: ProjectTextures
) -> Game:
	return GameFromRawData.new(raw_dict, project_textures)


static func to_raw_dict(game: Game) -> Dictionary:
	var output: Dictionary = {}

	# State
	if game.state != GameStateParsing.DEFAULT_STATE:
		output[_STATUS_KEY] = GameStateParsing.to_raw_string(game.state)

	# RNG
	var rng_data: Dictionary = RNGParsing.to_raw_dict(game.rng)
	if not rng_data.is_empty():
		output.merge({ _RNG_KEY: rng_data })

	# Players
	var players_data: Array = GamePlayerParsing.to_raw_array(game.game_players)
	if not players_data.is_empty():
		output.merge({ _PLAYERS_KEY: players_data })

	# Countries
	var countries_data: Array = CountryParsing.to_raw_array(game.countries)
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

	# Components
	var components_data: Dictionary = _components_to_raw_dict(game.components)
	if not components_data.is_empty():
		output.merge({ _COMPONENTS_KEY: components_data })

	return output


static func _components_from_raw_data(
		raw_data: Variant
) -> Dictionary[String, GameComponent]:
	var output: Dictionary[String, GameComponent] = {}

	if raw_data is not Dictionary:
		return output
	var raw_dict := raw_data as Dictionary

	for raw_key: Variant in raw_dict:
		if raw_key is not String:
			continue
		var key := raw_key as String

		var settings_data: Variant = raw_dict[key]
		if settings_data is not Dictionary:
			continue
		var settings_dict := settings_data as Dictionary

		var parse_result: GameComponent.ParseResult = (
				GameComponent.from_raw_data(key, settings_dict)
		)
		if parse_result.error:
			continue
		output[key] = parse_result.result_component

	return output


static func _components_to_raw_dict(
		components: Dictionary[String, GameComponent]
) -> Dictionary:
	var output: Dictionary = {}
	for component: GameComponent in components.values():
		output[component.KEY] = component.to_raw_dict()
	return output


class GameFromRawData extends Game:
	func _init(raw_dict: Dictionary, project_textures: ProjectTextures) -> void:
		# State
		state = GameStateParsing.from_raw_data(raw_dict.get(_STATUS_KEY))

		# RNG
		rng = RNGParsing.from_raw_data(raw_dict.get(_RNG_KEY), state)

		# Turn
		turn = (
				TurnParsing.from_raw_data(raw_dict.get(_TURN_KEY))
				.game_turn(self)
		)

		# Countries
		CountryParsing.load_from_raw_data(raw_dict.get(_COUNTRIES_KEY), self)

		# Players
		GamePlayerParsing.load_from_raw_data(raw_dict.get(_PLAYERS_KEY), self)

		# World
		WorldParsing.load_from_raw_data(
				raw_dict.get(_WORLD_KEY), self, project_textures
		)

		# Components
		components = GameParsing._components_from_raw_data(
				raw_dict.get(_COMPONENTS_KEY)
		)

		super()


class GameStateParsing:
	const DEFAULT_STATE: Game.GameState = Game.GameState.SETUP
	const _STATE_SETUP: String = "setup"
	const _STATE_ONGOING: String = "ongoing"
	const _STATE_GAMEOVER: String = "gameover"

	static func from_raw_data(raw_data: Variant) -> Game.GameState:
		match raw_data:
			null:
				return DEFAULT_STATE
			_STATE_SETUP:
				return Game.GameState.SETUP
			_STATE_ONGOING:
				return Game.GameState.ONGOING
			_STATE_GAMEOVER:
				return Game.GameState.GAMEOVER
			_:
				push_warning(
						"Unrecognized game state. Defaulting to setup phase"
				)
				return DEFAULT_STATE

	static func to_raw_string(game_state: Game.GameState) -> String:
		match game_state:
			Game.GameState.SETUP:
				return _STATE_SETUP
			Game.GameState.ONGOING:
				return _STATE_ONGOING
			Game.GameState.GAMEOVER:
				return _STATE_GAMEOVER
			_:
				return _STATE_SETUP
