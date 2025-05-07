class_name GameToRawDict
## Converts a [Game] into raw data.
##
## See also: [GameFromRaw]

var result: Variant


func convert_game(game: Game, game_settings: GameSettings) -> void:
	var json_data: Dictionary = {
		GameFromRaw.VERSION_KEY: GameFromRaw.SAVE_DATA_VERSION,
	}

	# Rules
	var rules_data: Dictionary = RulesToRawDict.parsed_from(game.rules)
	if not rules_data.is_empty():
		json_data.merge({ GameFromRaw.RULES_KEY: rules_data })

	# RNG
	json_data.merge(
			{ GameFromRaw.RNG_KEY: RNGToRawDict.new().result(game.rng) }
	)

	# Players
	var players_data: Array = game.game_players.raw_data()
	if not players_data.is_empty():
		json_data.merge({ GameFromRaw.PLAYERS_KEY: players_data })

	# Countries
	var countries_data: Array = _countries_to_raw_array(game.countries.list())
	if not countries_data.is_empty():
		json_data.merge({ GameFromRaw.COUNTRIES_KEY: countries_data })

	# World
	var world_data: Dictionary = _world_to_raw_dict(game.world, game_settings)
	if not world_data.is_empty():
		json_data.merge({ GameFromRaw.WORLD_KEY: world_data })

	# Turn
	var turn_data: Dictionary = _turn_to_raw_dict(game.turn)
	if not turn_data.is_empty():
		json_data.merge({ GameFromRaw.TURN_KEY: turn_data })

	# Background color
	if (
			game_settings.background_color.value
			!= GameSettings.DEFAULT_BACKGROUND_COLOR
	):
		json_data.merge({
			GameFromRaw.BACKGROUND_COLOR_KEY:
				game_settings.background_color.value.to_html(false)
		})

	result = json_data


func _countries_to_raw_array(country_list: Array[Country]) -> Array:
	var output: Array = []

	for country in country_list:
		var country_data: Dictionary = {
			CountriesFromRaw.COUNTRY_ID_KEY: country.id,
		}

		if country.country_name != "":
			country_data.merge({
				CountriesFromRaw.COUNTRY_NAME_KEY: country.country_name
			})

		if country.color != Country.DEFAULT_COLOR:
			country_data.merge({
				# Don't include transparency
				CountriesFromRaw.COUNTRY_COLOR_KEY:
					country.color.to_html(false)
			})

		if country.money != 0:
			country_data.merge({
				CountriesFromRaw.COUNTRY_MONEY_KEY: country.money
			})

		# Relationships
		var raw_relationships: Array = (
				DiplomacyRelationshipsToRaw.new().result(country.relationships)
		)
		if not raw_relationships.is_empty():
			country_data.merge({
				CountryRelationshipsFromRaw.COUNTRY_RELATIONSHIPS_KEY:
					raw_relationships
			})

		# Notifications
		var raw_notifications: Array = (
				GameNotificationsToRaw.new().result(country.notifications)
		)
		if not raw_notifications.is_empty():
			country_data.merge({
				CountryNotificationsFromRaw.COUNTRY_NOTIFICATIONS_KEY:
					raw_notifications
			})

		# Autoarrows
		var raw_auto_arrows: Array = (
				AutoArrowsToRaw.new().result(country.auto_arrows)
		)
		if not raw_auto_arrows.is_empty():
			country_data.merge({
				AutoArrowsFromRaw.COUNTRY_AUTOARROWS_KEY: raw_auto_arrows
			})

		output.append(country_data)

	return output


func _world_to_raw_dict(
		world: GameWorld, game_settings: GameSettings
) -> Dictionary:
	var output: Dictionary = {}

	# World limits
	var limits_data: Dictionary = (
			WorldLimitsToRaw.result(game_settings.world_limits)
	)
	if not limits_data.is_empty():
		output.merge({ WorldFromRaw.WORLD_LIMITS_KEY: limits_data })

	# Provinces
	var provinces_data: Array = _provinces_to_raw_array(world.provinces.list())
	if not provinces_data.is_empty():
		output.merge(
				{ WorldFromRaw.WORLD_PROVINCES_KEY: provinces_data }
		)

	# Armies
	var armies_data: Array = _armies_to_raw_array(world.armies.list())
	if not armies_data.is_empty():
		output.merge(
				{ WorldFromRaw.WORLD_ARMIES_KEY: armies_data }
		)

	return output


func _provinces_to_raw_array(province_list: Array[Province]) -> Array:
	var output: Array = []

	for province in province_list:
		var province_data: Dictionary = {
			ProvincesFromRaw.PROVINCE_ID_KEY: province.id,
			ProvincesFromRaw.PROVINCE_POSITION_KEY: {
				ProvincesFromRaw.PROVINCE_POS_X_KEY: province.position.x,
				ProvincesFromRaw.PROVINCE_POS_Y_KEY: province.position.y,
			},
		}
		if province.income_money() is IncomeMoneyConstant:
			province_data.merge({
				ProvincesFromRaw.PROVINCE_INCOME_MONEY_KEY:
					province.income_money().total(),
			})

		var global_position_army_host: Vector2 = (
				province.position + province.position_army_host
		)
		province_data.merge({
			ProvincesFromRaw.PROVINCE_POSITION_ARMY_HOST_X_KEY:
				global_position_army_host.x,
			ProvincesFromRaw.PROVINCE_POSITION_ARMY_HOST_Y_KEY:
				global_position_army_host.y,
		})

		# 4.0 backwards compatibility:
		# Data must always have a province owner id.
		province_data.merge({
			ProvincesFromRaw.PROVINCE_OWNER_ID_KEY: (
					province.owner_country.id
					if province.owner_country != null else -1
			)
		})

		# Links
		if not province.links.is_empty():
			var links_json: Array = []
			for link in province.links:
				links_json.append(link.id)
			province_data.merge(
					{ ProvincesFromRaw.PROVINCE_LINKS_KEY: links_json }
			)

		# Shape
		if not province.polygon.is_empty():
			var shape_vertices_x: Array = []
			var shape_vertices_y: Array = []
			for i in province.polygon.size():
				shape_vertices_x.append(province.polygon[i].x)
				shape_vertices_y.append(province.polygon[i].y)
			province_data.merge({
				ProvincesFromRaw.PROVINCE_SHAPE_KEY: {
					ProvincesFromRaw.PROVINCE_SHAPE_X_KEY: shape_vertices_x,
					ProvincesFromRaw.PROVINCE_SHAPE_Y_KEY: shape_vertices_y,
				}
			})

		# Population
		if province.population.population_size != 0:
			province_data.merge({
				ProvincesFromRaw.PROVINCE_POPULATION_KEY: {
					ProvincesFromRaw.POPULATION_SIZE_KEY:
						province.population.population_size,
				}
			})

		# Buildings
		var buildings_data: Array = []
		for building in province.buildings.list():
			# 4.0 backwards compatibility: building type must be a string.
			buildings_data.append({
				ProvincesFromRaw.BUILDING_TYPE_KEY:
					ProvincesFromRaw.BUILDING_TYPE_FORTRESS
			})
		# 4.0 backwards compatibility: data must always have a buildings array.
		province_data.merge({
			ProvincesFromRaw.PROVINCE_BUILDINGS_KEY: buildings_data,
		})

		output.append(province_data)

	return output


func _armies_to_raw_array(armies_list: Array[Army]) -> Array:
	var output: Array = []

	for army in armies_list:
		var army_data: Dictionary = {
			ArmiesFromRaw.ARMY_ID_KEY: army.id,
			ArmiesFromRaw.ARMY_SIZE_KEY: army.army_size.current_size(),
			ArmiesFromRaw.ARMY_OWNER_ID_KEY: army.owner_country.id,
			ArmiesFromRaw.ARMY_PROVINCE_ID_KEY: army.province().id,
		}

		# Movements made (only include this when it's not the default 0)
		if army.movements_made() != 0:
			army_data.merge(
					{ ArmiesFromRaw.ARMY_MOVEMENTS_KEY: army.movements_made() }
			)

		output.append(army_data)

	return output


func _turn_to_raw_dict(turn: GameTurn) -> Dictionary:
	var turn_data: Dictionary = {
		TurnFromRaw.TURN_KEY: turn.current_turn(),
		TurnFromRaw.PLAYER_INDEX_KEY: turn._playing_player_index,
	}

	if turn.current_turn() == 1:
		turn_data.erase(TurnFromRaw.TURN_KEY)
	if turn._playing_player_index == 0:
		turn_data.erase(TurnFromRaw.PLAYER_INDEX_KEY)

	return turn_data
