class_name GameParsing
## Parses [Game] data.

const _RULES_KEY: String = "rules"
const _RNG_KEY: String = "rng"
const _TURN_KEY: String = "turn"
const _WORLD_KEY: String = "world"
const _COUNTRIES_KEY: String = "countries"
const _PLAYERS_KEY: String = "players"
const _BACKGROUND_COLOR_KEY: String = "background_color"


static func game_from_raw_dict(
		raw_dict: Dictionary,
		project_file_path: String,
		game_settings: GameSettings
) -> Game:
	return GameFromRawData.new(raw_dict, project_file_path, game_settings)


static func game_to_raw_dict(
		game: Game, game_settings: GameSettings
) -> Dictionary:
	var output: Dictionary = {}

	# Rules
	var rules_data: Dictionary = RulesToRawDict.result(game.rules)
	if not rules_data.is_empty():
		output.merge({ _RULES_KEY: rules_data })

	# RNG
	output.merge({ _RNG_KEY: RNGToRawDict.result(game.rng) })

	# Players
	var players_data: Array = game.game_players.raw_data()
	if not players_data.is_empty():
		output.merge({ _PLAYERS_KEY: players_data })

	# Countries
	var countries_data: Array = game.countries.to_raw_array()
	if not countries_data.is_empty():
		output.merge({ _COUNTRIES_KEY: countries_data })

	# World
	var world_data: Dictionary = _world_to_raw_dict(game.world, game_settings)
	if not world_data.is_empty():
		output.merge({ _WORLD_KEY: world_data })

	# Turn
	var turn_data: Dictionary = _turn_to_raw_dict(game.turn)
	if not turn_data.is_empty():
		output.merge({ _TURN_KEY: turn_data })

	# Background color
	if (
			game_settings.background_color.value
			!= GameSettings.DEFAULT_BACKGROUND_COLOR
	):
		output.merge({
			_BACKGROUND_COLOR_KEY:
				game_settings.background_color.value.to_html(false)
		})

	return output


static func _world_to_raw_dict(
		world: GameWorld, game_settings: GameSettings
) -> Dictionary:
	var output: Dictionary = {}

	# World limits
	var limits_data: Variant = game_settings.world_limits.to_raw_data()
	if not ParseUtils.is_empty_dict(limits_data):
		output.merge({ WorldFromRaw.WORLD_LIMITS_KEY: limits_data })

	# Provinces
	var provinces_data: Array = _provinces_to_raw_array(world.provinces.list())
	if not provinces_data.is_empty():
		output.merge({ WorldFromRaw.WORLD_PROVINCES_KEY: provinces_data })

	# Armies
	var armies_data: Array = _armies_to_raw_array(world.armies.list())
	if not armies_data.is_empty():
		output.merge({ WorldFromRaw.WORLD_ARMIES_KEY: armies_data })

	# Decorations
	var decoration_data: Array = (
			WorldDecorationsToRaw.result(world.decorations)
	)
	if not decoration_data.is_empty():
		output.merge({ WorldFromRaw.WORLD_DECORATIONS_KEY: decoration_data })

	return output


static func _provinces_to_raw_array(province_list: Array[Province]) -> Array:
	var output: Array = []

	for province in province_list:
		var province_data: Dictionary = {
			ProvincesFromRaw.PROVINCE_ID_KEY: province.id
		}

		# Name
		if province.name != "":
			province_data.merge(
					{ ProvincesFromRaw.PROVINCE_NAME_KEY: province.name }
			)

		# Owner country
		if province.owner_country != null:
			province_data.merge({
				ProvincesFromRaw.PROVINCE_OWNER_ID_KEY:
					province.owner_country.id
			})

		# Links
		if not province.linked_province_ids().is_empty():
			province_data.merge({
				ProvincesFromRaw.PROVINCE_LINKS_KEY:
					Array(province.linked_province_ids().duplicate())
			})

		# Shape
		if Array(province.polygon().array) != Province.DEFAULT_POLYGON_SHAPE:
			var shape_vertices_x: Array = []
			var shape_vertices_y: Array = []
			for i in province.polygon().array.size():
				shape_vertices_x.append(province.polygon().array[i].x)
				shape_vertices_y.append(province.polygon().array[i].y)
			province_data.merge({
				ProvincesFromRaw.PROVINCE_SHAPE_KEY: {
					ProvincesFromRaw.PROVINCE_SHAPE_X_KEY: shape_vertices_x,
					ProvincesFromRaw.PROVINCE_SHAPE_Y_KEY: shape_vertices_y,
				}
			})

		# Position army host
		if province.position_army_host.x != 0.0:
			province_data.merge({
				ProvincesFromRaw.PROVINCE_POSITION_ARMY_HOST_X_KEY:
					province.position_army_host.x
			})
		if province.position_army_host.y != 0.0:
			province_data.merge({
				ProvincesFromRaw.PROVINCE_POSITION_ARMY_HOST_Y_KEY:
					province.position_army_host.y
			})

		# Population
		if province.population().value != 0:
			province_data.merge({
				ProvincesFromRaw.PROVINCE_POPULATION_KEY: {
					ProvincesFromRaw.POPULATION_SIZE_KEY:
						province.population().value,
				}
			})

		# Money income
		if province.base_money_income().value != 0:
			province_data.merge({
				ProvincesFromRaw.PROVINCE_INCOME_MONEY_KEY:
					province.base_money_income().value
			})

		# Buildings
		var buildings_data: Array = []
		for building in province.buildings.list():
			# 4.0 backwards compatibility: building type must be a string.
			buildings_data.append({
				ProvincesFromRaw.BUILDING_TYPE_KEY:
					ProvincesFromRaw.BUILDING_TYPE_FORTRESS
			})
		if not buildings_data.is_empty():
			province_data.merge({
				ProvincesFromRaw.PROVINCE_BUILDINGS_KEY: buildings_data
			})

		output.append(province_data)

	return output


static func _armies_to_raw_array(armies_list: Array[Army]) -> Array:
	var output: Array = []

	for army in armies_list:
		var army_data: Dictionary = {
			ArmiesFromRaw.ARMY_ID_KEY: army.id,
			ArmiesFromRaw.ARMY_SIZE_KEY: army.army_size.current_size(),
			ArmiesFromRaw.ARMY_OWNER_ID_KEY: army.owner_country.id,
			ArmiesFromRaw.ARMY_PROVINCE_ID_KEY: army.province_id(),
		}

		# Movements made (only include this when it's not the default 0)
		if army.movements_made() != 0:
			army_data.merge(
					{ ArmiesFromRaw.ARMY_MOVEMENTS_KEY: army.movements_made() }
			)

		output.append(army_data)

	return output


static func _turn_to_raw_dict(turn: GameTurn) -> Dictionary:
	var turn_data: Dictionary = {
		TurnFromRaw.TURN_KEY: turn.current_turn(),
		TurnFromRaw.PLAYER_INDEX_KEY: turn._playing_player_index,
	}

	if turn.current_turn() == 1:
		turn_data.erase(TurnFromRaw.TURN_KEY)
	if turn._playing_player_index == 0:
		turn_data.erase(TurnFromRaw.PLAYER_INDEX_KEY)

	return turn_data


class GameFromRawData extends Game:
	func _init(
		raw_dict: Dictionary,
		project_file_path: String,
		game_settings: GameSettings
) -> void:
		# Rules
		rules = RulesFromRaw.parsed_from(raw_dict.get(_RULES_KEY))

		# RNG
		rng = RNGFromRaw.parsed_from(raw_dict.get(_RNG_KEY))

		# Turn
		turn = TurnFromRaw.parsed_from(raw_dict.get(_TURN_KEY)).game_turn(self)

		# Countries
		var country_data: Variant = raw_dict.get(_COUNTRIES_KEY)
		countries = Countries.from_raw_data(country_data)

		# Relationships
		CountryRelationshipsFromRaw.parse_using(country_data, self)

		# Players
		GamePlayersFromRaw.parse_using(raw_dict.get(_PLAYERS_KEY), self)

		# Notifications
		CountryNotificationsFromRaw.parse_using(country_data, self)

		# World
		WorldFromRaw.parse_using(
				raw_dict.get(_WORLD_KEY),
				self,
				game_settings,
				project_file_path
		)

		# Background color
		if raw_dict.has(_BACKGROUND_COLOR_KEY):
			var background_color: Color = ParseUtils.color_from_raw(
					raw_dict.get(_BACKGROUND_COLOR_KEY),
					GameSettings.DEFAULT_BACKGROUND_COLOR
			)
			game_settings.background_color.value = background_color

		super()
