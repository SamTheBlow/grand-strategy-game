class_name GameToRawDict
## Converts a [Game] into raw data.
##
## See also: [GameFromRawDict]


var error: bool = true
var error_message: String = ""
var result: Variant


func convert_game(game: Game) -> void:
	var json_data: Dictionary = {}
	
	json_data[GameFromRawDict.VERSION_KEY] = GameFromRawDict.SAVE_DATA_VERSION
	
	# Rules
	var rules_data: Dictionary = RulesToRawDict.new().result(game.rules)
	if not rules_data.is_empty():
		json_data[GameFromRawDict.RULES_KEY] = rules_data
	
	# RNG
	json_data[GameFromRawDict.RNG_KEY] = RNGToRawDict.new().result(game.rng)
	
	# Players
	json_data[GameFromRawDict.PLAYERS_KEY] = game.game_players.raw_data()
	
	# Countries
	var countries_data: Array = []
	for country in game.countries.list():
		var country_data: Dictionary = {
			GameFromRawDict.COUNTRY_ID_KEY: country.id,
			GameFromRawDict.COUNTRY_NAME_KEY: country.country_name,
			# Intentionally don't include transparency for the country color
			GameFromRawDict.COUNTRY_COLOR_KEY: country.color.to_html(false),
			GameFromRawDict.COUNTRY_MONEY_KEY: country.money,
		}
		
		# Relationships
		var raw_relationships: Array = (
				DiplomacyRelationshipsToRaw.new().result(country.relationships)
		)
		if raw_relationships.size() > 0:
			country_data[GameFromRawDict.COUNTRY_RELATIONSHIPS_KEY] = (
					raw_relationships
			)
		
		# Notifications
		var raw_notifications: Array = (
				GameNotificationsToRaw.new().result(country.notifications)
		)
		if raw_notifications.size() > 0:
			country_data[GameFromRawDict.COUNTRY_NOTIFICATIONS_KEY] = (
					raw_notifications
			)
		
		# Autoarrows
		var raw_auto_arrows: Array = (
				AutoArrowsToRaw.new().result(country.auto_arrows)
		)
		if raw_auto_arrows.size() > 0:
			country_data[GameFromRawDict.COUNTRY_AUTOARROWS_KEY] = (
					raw_auto_arrows
			)
		
		countries_data.append(country_data)
	json_data[GameFromRawDict.COUNTRIES_KEY] = countries_data
	
	# World
	var world_data: Dictionary = {}
	
	if game.world is GameWorld2D:
		var world := game.world as GameWorld2D
		world_data[GameFromRawDict.WORLD_LIMITS_KEY] = {
			GameFromRawDict.WORLD_LIMIT_TOP_KEY: world.limits.limit_top(),
			GameFromRawDict.WORLD_LIMIT_BOTTOM_KEY: world.limits.limit_bottom(),
			GameFromRawDict.WORLD_LIMIT_LEFT_KEY: world.limits.limit_left(),
			GameFromRawDict.WORLD_LIMIT_RIGHT_KEY: world.limits.limit_right(),
		}
	
	# Provinces
	var provinces_data: Array = []
	for province in game.world.provinces.list():
		var province_data: Dictionary = {
			GameFromRawDict.PROVINCE_ID_KEY: province.id,
			GameFromRawDict.PROVINCE_POSITION_KEY: {
					GameFromRawDict.PROVINCE_POS_X_KEY: province.position.x,
					GameFromRawDict.PROVINCE_POS_Y_KEY: province.position.y,
				},
		}
		if province.income_money() is IncomeMoneyConstant:
			province_data.merge({
				GameFromRawDict.PROVINCE_INCOME_MONEY_KEY:
					province.income_money().total(),
			})
		
		var global_position_army_host: Vector2 = (
				province.position + province.position_army_host
		)
		province_data.merge({
			GameFromRawDict.PROVINCE_POSITION_ARMY_HOST_X_KEY:
				global_position_army_host.x,
			GameFromRawDict.PROVINCE_POSITION_ARMY_HOST_Y_KEY:
				global_position_army_host.y,
		})
		
		# 4.0 backwards compatibility: data must always have a province owner id.
		province_data[GameFromRawDict.PROVINCE_OWNER_ID_KEY] = (
				province.owner_country.id
				if province.owner_country != null else -1
		)
		
		# Links
		var links_json: Array = []
		for link in province.links:
			links_json.append(link.id)
		province_data[GameFromRawDict.PROVINCE_LINKS_KEY] = links_json
		
		# Shape
		var shape_vertices := Array(province.polygon)
		var shape_vertices_x: Array = []
		var shape_vertices_y: Array = []
		for i in shape_vertices.size():
			shape_vertices_x.append(shape_vertices[i].x)
			shape_vertices_y.append(shape_vertices[i].y)
		province_data[GameFromRawDict.PROVINCE_SHAPE_KEY] = {
			GameFromRawDict.PROVINCE_SHAPE_X_KEY: shape_vertices_x,
			GameFromRawDict.PROVINCE_SHAPE_Y_KEY: shape_vertices_y,
		}
		
		# Population
		province_data[GameFromRawDict.PROVINCE_POPULATION_KEY] = {
			GameFromRawDict.POPULATION_SIZE_KEY:
				province.population.population_size,
		}
		
		# Buildings
		var buildings_data: Array = []
		for building in province.buildings.list():
			# 4.0 backwards compatibility: building type must be a string.
			buildings_data.append({
				GameFromRawDict.BUILDING_TYPE_KEY:
					GameFromRawDict.BUILDING_TYPE_FORTRESS
			})
		# 4.0 backwards compatibility: data must always have a buildings array.
		province_data.merge({
			GameFromRawDict.PROVINCE_BUILDINGS_KEY: buildings_data,
		})
		
		provinces_data.append(province_data)
	world_data[GameFromRawDict.WORLD_PROVINCES_KEY] = provinces_data
	
	# Armies
	var armies_data: Array = []
	for army in game.world.armies.list():
		var army_data: Dictionary = {
			GameFromRawDict.ARMY_ID_KEY: army.id,
			GameFromRawDict.ARMY_SIZE_KEY: army.army_size.current_size(),
			GameFromRawDict.ARMY_OWNER_ID_KEY: army.owner_country.id,
			GameFromRawDict.ARMY_PROVINCE_ID_KEY: army.province().id,
		}
		
		# Movements made (only include this when it's not the default 0)
		if army.movements_made() != 0:
			army_data.merge({
				GameFromRawDict.ARMY_MOVEMENTS_KEY: army.movements_made(),
			})
		
		armies_data.append(army_data)
	world_data[GameFromRawDict.WORLD_ARMIES_KEY] = armies_data
	
	json_data[GameFromRawDict.WORLD_KEY] = world_data
	
	# Turn
	json_data[GameFromRawDict.TURN_KEY] = {
		GameFromRawDict.TURN_TURN_KEY: game.turn.current_turn(),
		GameFromRawDict.TURN_PLAYER_INDEX_KEY: game.turn._playing_player_index,
	}
	
	# Success!
	error = false
	result = json_data
