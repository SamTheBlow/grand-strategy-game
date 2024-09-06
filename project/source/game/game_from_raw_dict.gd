class_name GameFromRawDict
## Converts raw data into a new [Game].
##
## See also: [GameToRawDict]
# TODO tons of stuff in here needs to verify & return errors
# TODO separate into smaller classes


const VERSION_KEY: String = "version"
const RULES_KEY: String = "rules"
const RNG_KEY: String = "rng"
const TURN_KEY: String = "turn"
const WORLD_KEY: String = "world"
const COUNTRIES_KEY: String = "countries"
const PLAYERS_KEY: String = "players"

# Specific to [GameTurn] data
const TURN_TURN_KEY: String = "turn"
const TURN_PLAYER_INDEX_KEY: String = "playing_player_index"

# Specific to [GameWorld] data
const WORLD_LIMITS_KEY: String = "limits"
const WORLD_PROVINCES_KEY: String = "provinces"
const WORLD_ARMIES_KEY: String = "armies"

# Specific to [WorldLimits] data
const WORLD_LIMIT_LEFT_KEY: String = "left"
const WORLD_LIMIT_TOP_KEY: String = "top"
const WORLD_LIMIT_RIGHT_KEY: String = "right"
const WORLD_LIMIT_BOTTOM_KEY: String = "bottom"

# Specific to [Country] data
const COUNTRY_ID_KEY: String = "id"
const COUNTRY_NAME_KEY: String = "country_name"
const COUNTRY_COLOR_KEY: String = "color"
const COUNTRY_MONEY_KEY: String = "money"
const COUNTRY_RELATIONSHIPS_KEY: String = "relationships"
const COUNTRY_NOTIFICATIONS_KEY: String = "notifications"
const COUNTRY_AUTOARROWS_KEY: String = "auto_arrows"

# Specific to [GamePlayer] data
const PLAYER_ID_KEY: String = "id"
const PLAYER_COUNTRY_ID_KEY: String = "playing_country_id"
const PLAYER_IS_HUMAN_KEY: String = "is_human"
const PLAYER_USERNAME_KEY: String = "username"
const PLAYER_HUMAN_ID_KEY: String = "human_id"
const PLAYER_AI_TYPE_KEY: String = "ai_type"
const PLAYER_AI_PERSONALITY_KEY: String = "ai_personality_type"

# Specific to [Province] data
const PROVINCE_ID_KEY: String = "id"
const PROVINCE_LINKS_KEY: String = "links"
const PROVINCE_POSITION_ARMY_HOST_X_KEY: String = "position_army_host_x"
const PROVINCE_POSITION_ARMY_HOST_Y_KEY: String = "position_army_host_y"
const PROVINCE_SHAPE_KEY: String = "shape"
const PROVINCE_POSITION_KEY: String = "position"
const PROVINCE_POS_X_KEY: String = "x"
const PROVINCE_POS_Y_KEY: String = "y"
const PROVINCE_OWNER_ID_KEY: String = "owner_country_id"
const PROVINCE_POPULATION_KEY: String = "population"
const PROVINCE_BUILDINGS_KEY: String = "buildings"
const PROVINCE_INCOME_MONEY_KEY: String = "income_money"

# Specific to province shape data
const PROVINCE_SHAPE_X_KEY: String = "x"
const PROVINCE_SHAPE_Y_KEY: String = "y"

# Specific to [Population] data
const POPULATION_SIZE_KEY: String = "size"

# Specific to [Building] data
const BUILDING_TYPE_KEY: String = "type"
const BUILDING_TYPE_FORTRESS: String = "fortress"

# Specific to [Army] data
const ARMY_MOVEMENTS_KEY: String = "number_of_movements_made"
const ARMY_ID_KEY: String = "id"
const ARMY_SIZE_KEY: String = "army_size"
const ARMY_OWNER_ID_KEY: String = "owner_country_id"
const ARMY_PROVINCE_ID_KEY: String = "province_id"

# 4.0 Backwards compatibility: can't use a different value
## The format version. If changes need to be made in the future
## to how the game is saved and loaded, this will allow us to tell
## if a file was made in an older or a newer version.
const SAVE_DATA_VERSION: String = "1"

var error: bool = false
var error_message: String = ""
var result: Game


func load_game(json_data: Variant) -> void:
	error = false
	error_message = ""
	
	if not json_data is Dictionary:
		error = true
		error_message = "JSON data's root is not a dictionary."
		return
	var json_dict: Dictionary = json_data
	
	# Check version
	if not json_dict.has(VERSION_KEY):
		error = true
		error_message = "JSON data doesn't have a \"version\" property."
		return
	var version: String = json_dict[VERSION_KEY]
	if version != SAVE_DATA_VERSION:
		error = true
		error_message = "Save data is from an unrecognized version."
		return
	
	# Loading begins!
	var game := Game.new()
	
	# Rules
	var rules_dict: Dictionary = {}
	if ParseUtils.dictionary_has_dictionary(json_dict, RULES_KEY):
		rules_dict = json_dict[RULES_KEY]
	game.rules = RulesFromRawDict.new().result(rules_dict)
	
	# RNG
	# 4.0 Backwards compatibility: can't require RNG to be in the save data.
	if ParseUtils.dictionary_has_dictionary(json_dict, RNG_KEY):
		game.rng = RNGFromRawDict.new().result(json_dict[RNG_KEY])
	
	# Turn
	if json_dict.has(TURN_KEY):
		if not json_dict[TURN_KEY] is Dictionary:
			error = true
			error_message = "Turn property (in root) is not a dictionary."
			return
		var turn_dict: Dictionary = json_dict[TURN_KEY]
		
		if not turn_dict.has(TURN_TURN_KEY):
			error = true
			error_message = "Cannot find turn property."
			return
		if not ParseUtils.is_number(turn_dict[TURN_TURN_KEY]):
			error = true
			error_message = "Turn property is not a number."
			return
		var turn: int = ParseUtils.number_as_int(turn_dict[TURN_TURN_KEY])
		
		if not turn_dict.has(TURN_PLAYER_INDEX_KEY):
			error = true
			error_message = "Cannot find playing player index property."
			return
		if not ParseUtils.is_number(turn_dict[TURN_PLAYER_INDEX_KEY]):
			error = true
			error_message = "Playing player index is not a number."
			return
		var playing_player_index: int = ParseUtils.number_as_int(
				turn_dict[TURN_PLAYER_INDEX_KEY]
		)
		
		game.setup_turn(turn, playing_player_index)
	else:
		game.setup_turn()
	
	# Countries
	for country in _loaded_countries(json_dict):
		game.countries.add(country)
	if error:
		return
	
	# We need all the countries to be loaded
	# before we can load their relationships
	_load_diplomacy_relationships(json_dict, game)
	if error:
		return
	
	# Players
	if not _load_players(json_dict, game):
		return
	
	# We need countries and players to be loaded
	# before we can load the notifications
	_load_game_notifications(json_dict, game)
	if error:
		return
	
	# World
	var world := GameWorld2D.new()
	game.world = world
	# TASK verify & return errors
	if not (
			json_dict.has(WORLD_KEY)
			and json_dict[WORLD_KEY].has(WORLD_LIMITS_KEY)
			and json_dict[WORLD_KEY].has(WORLD_PROVINCES_KEY)
	):
		error = true
		error_message = "World data is missing."
		return
	
	# Camera limits
	var limits_data: Dictionary = json_dict[WORLD_KEY][WORLD_LIMITS_KEY]
	if not _load_world_limits(limits_data, world.limits):
		return
	
	# Provinces
	for province_data: Dictionary in json_dict[WORLD_KEY][WORLD_PROVINCES_KEY]:
		var province: Province = _load_province(province_data, game)
		if not province:
			return
		world.provinces.add_province(province)
	# 2nd loop for links
	for province_data: Dictionary in json_dict[WORLD_KEY][WORLD_PROVINCES_KEY]:
		var province: Province = (
				world.provinces.province_from_id(province_data[PROVINCE_ID_KEY])
		)
		province.links = []
		for link: int in province_data[PROVINCE_LINKS_KEY]:
			province.links.append(world.provinces.province_from_id(link))
	
	# Armies
	var armies_error: bool = _load_armies(
			json_dict[WORLD_KEY][WORLD_ARMIES_KEY], game
	)
	if armies_error:
		return
	
	# Auto arrows
	# We have to load these after the provinces
	_load_auto_arrows(json_dict, game)
	
	# Success!
	result = game


func _loaded_countries(json_data: Dictionary) -> Array[Country]:
	var countries: Array[Country] = []
	
	if not json_data.has(COUNTRIES_KEY):
		error = true
		error_message = "No countries found in file."
		return []
	if not json_data[COUNTRIES_KEY] is Array:
		error = true
		error_message = "Countries property is not an array."
		return []
	var countries_data: Array = json_data[COUNTRIES_KEY]
	
	for country_data: Variant in countries_data:
		if not country_data is Dictionary:
			error = true
			error_message = "Country data is not a dictionary."
			return []
		var country_dict: Dictionary = country_data
		
		var country: Country = _load_country(country_dict)
		if country == null:
			return []
		countries.append(country)
	
	return countries


# TASK verify & return errors
func _load_country(json_data: Dictionary) -> Country:
	var country := Country.new()
	
	country.id = json_data[COUNTRY_ID_KEY]
	country.country_name = json_data[COUNTRY_NAME_KEY]
	country.color = Color(json_data[COUNTRY_COLOR_KEY])
	
	if json_data.has(COUNTRY_MONEY_KEY):
		country.money = json_data[COUNTRY_MONEY_KEY]
	
	country.notifications = GameNotifications.new()
	
	return country


func _load_diplomacy_relationships(json_dict: Dictionary, game: Game) -> void:
	# TODO DRY. a lot of copy/paste from _load_auto_arrows()
	if not json_dict.has(COUNTRIES_KEY):
		return
	
	var countries_data: Variant = json_dict[COUNTRIES_KEY]
	if not (countries_data is Array):
		return
	var countries_array := countries_data as Array
	
	if countries_array.size() < game.countries.size():
		return
	
	var default_relationship_data: Dictionary = (
			DiplomacyRelationships.new_default_data(game.rules)
	)
	var base_actions: Array[int] = (
			DiplomacyRelationships.new_base_actions(game.rules)
	)
	
	# We have to create all the relationships objects first
	var country_list: Array[Country] = game.countries.list()
	for country in country_list:
		country.relationships = DiplomacyRelationships.new(
				game, country, default_relationship_data, base_actions
		)
	
	for i in country_list.size():
		if not (countries_array[i] is Dictionary):
			continue
		var country_dict := countries_array[i] as Dictionary
		
		if not (
				country_dict.has(COUNTRY_RELATIONSHIPS_KEY)
				and country_dict[COUNTRY_RELATIONSHIPS_KEY] is Array
		):
			continue
		
		var country: Country = country_list[i]
		var relationships_data := (
				country_dict[COUNTRY_RELATIONSHIPS_KEY] as Array
		)
		var relationships_from_raw := DiplomacyRelationshipsFromRaw.new()
		relationships_from_raw.apply(
				relationships_data,
				game,
				country,
				default_relationship_data,
				base_actions,
		)
		if relationships_from_raw.error:
			continue
		
		country.relationships = relationships_from_raw.result


func _load_game_notifications(json_dict: Dictionary, game: Game) -> void:
	# TASK DRY. a lot of copy/paste from _load_auto_arrows()
	if not json_dict.has(COUNTRIES_KEY):
		return
	
	var countries_data: Variant = json_dict[COUNTRIES_KEY]
	if not (countries_data is Array):
		return
	var countries_array := countries_data as Array
	
	if countries_array.size() < game.countries.size():
		return
	
	var country_list: Array[Country] = game.countries.list()
	for i in country_list.size():
		if not (countries_array[i] is Dictionary):
			continue
		var country_dict := countries_array[i] as Dictionary
		
		if not (
				country_dict.has(COUNTRY_NOTIFICATIONS_KEY)
				and country_dict[COUNTRY_NOTIFICATIONS_KEY] is Array
		):
			continue
		var notifications_array := (
				country_dict[COUNTRY_NOTIFICATIONS_KEY] as Array
		)
		
		var country: Country = country_list[i]
		
		var notifications_from_raw := GameNotificationsFromRaw.new()
		notifications_from_raw.apply(game, country, notifications_array)
		if notifications_from_raw.error:
			continue
		
		country.notifications = notifications_from_raw.result


func _load_auto_arrows(json_dict: Dictionary, game: Game) -> void:
	if not json_dict.has(COUNTRIES_KEY):
		return
	
	var countries_data: Variant = json_dict[COUNTRIES_KEY]
	if not (countries_data is Array):
		return
	var countries_array := countries_data as Array
	
	if countries_array.size() < game.countries.size():
		return
	
	var country_list: Array[Country] = game.countries.list()
	for i in country_list.size():
		if not (countries_array[i] is Dictionary):
			return
		var country_dict := countries_array[i] as Dictionary
		
		if not country_dict.has(COUNTRY_AUTOARROWS_KEY):
			continue
		
		country_list[i].auto_arrows = (
				AutoArrowsFromRaw.new()
				.result(game, country_dict[COUNTRY_AUTOARROWS_KEY])
		)


func _load_players(json_data: Dictionary, game: Game) -> bool:
	game.game_players = GamePlayers.new()
	
	if not json_data.has(PLAYERS_KEY):
		error = true
		error_message = "No players found in file."
		return false
	if not json_data[PLAYERS_KEY] is Array:
		error = true
		error_message = "Players property is not an array."
		return false
	var players_data: Array = json_data[PLAYERS_KEY]
	
	for player_data: Variant in players_data:
		if not player_data is Dictionary:
			error = true
			error_message = "Player data is not a dictionary."
			return false
		var player_dict: Dictionary = player_data
		
		var player: GamePlayer = _load_player(player_dict, game)
		if not player:
			return false
		game.game_players.add_player(player)
	
	return true


# TASK verify & return errors
## This function requires that game.game_players is already set
func _load_player(json_data: Dictionary, game: Game) -> GamePlayer:
	# AI type
	var ai_type: int = 0
	if ParseUtils.dictionary_has_number(json_data, PLAYER_AI_TYPE_KEY):
		var loaded_ai_type: int = (
				ParseUtils.dictionary_int(json_data, PLAYER_AI_TYPE_KEY)
		)
		if loaded_ai_type in PlayerAI.Type.values():
			ai_type = loaded_ai_type
	
	var player: GamePlayer = GamePlayer.new()
	player.id = json_data[PLAYER_ID_KEY]
	# The player is a spectator if there is no country id,
	# of if the country id is a negative number
	if json_data.has(PLAYER_COUNTRY_ID_KEY):
		var country_id: int = json_data[PLAYER_COUNTRY_ID_KEY]
		if country_id >= 0:
			player.playing_country = (
					game.countries.country_from_id(country_id)
			)
	if json_data.has(PLAYER_IS_HUMAN_KEY):
		player.is_human = json_data[PLAYER_IS_HUMAN_KEY]
	if json_data.has(PLAYER_USERNAME_KEY):
		if not json_data[PLAYER_USERNAME_KEY] is String:
			error = true
			error_message = "Player's username property is not a string."
			return null
		player.username = json_data[PLAYER_USERNAME_KEY]
	if json_data.has(PLAYER_HUMAN_ID_KEY):
		player.player_human_id = json_data[PLAYER_HUMAN_ID_KEY]
	player.player_ai = PlayerAI.from_type(ai_type)
	
	var ai_personality_id: int = (
			game.rules.default_ai_personality_option.selected
	)
	if ParseUtils.dictionary_has_number(json_data, PLAYER_AI_PERSONALITY_KEY):
		ai_personality_id = (
				ParseUtils.dictionary_int(json_data, PLAYER_AI_PERSONALITY_KEY)
		)
	var ai_personality: AIPersonality = (
			AIPersonality.from_type(ai_personality_id)
	)
	if ai_personality != null:
		player.player_ai.personality = ai_personality
	
	return player


# TASK verify & return errors
func _load_world_limits(json_data: Dictionary, limits: WorldLimits) -> bool:
	var x1: int = json_data[WORLD_LIMIT_LEFT_KEY]
	var y1: int = json_data[WORLD_LIMIT_TOP_KEY]
	var x2: int = json_data[WORLD_LIMIT_RIGHT_KEY]
	var y2: int = json_data[WORLD_LIMIT_BOTTOM_KEY]
	
	limits._limits = Rect2i(x1, y1, x2 - x1, y2 - y1)
	return true


# TASK verify & return errors
func _load_province(json_data: Dictionary, game: Game) -> Province:
	var province := Province.new()
	province.id = json_data[PROVINCE_ID_KEY]
	
	var shape_data: Dictionary = json_data[PROVINCE_SHAPE_KEY]
	var shape: PackedVector2Array = []
	for i in (shape_data[PROVINCE_SHAPE_X_KEY] as Array).size():
		shape.append(Vector2(
				shape_data[PROVINCE_SHAPE_X_KEY][i],
				shape_data[PROVINCE_SHAPE_Y_KEY][i]
		))
	province.polygon = shape
	
	province.position = Vector2(
			json_data[PROVINCE_POSITION_KEY][PROVINCE_POS_X_KEY],
			json_data[PROVINCE_POSITION_KEY][PROVINCE_POS_Y_KEY]
	)
	
	# 4.1 Backwards Compatibility:
	# This must be saved as a global position
	# (not relative to the province position).
	province.position_army_host = Vector2(
			json_data[PROVINCE_POSITION_ARMY_HOST_X_KEY],
			json_data[PROVINCE_POSITION_ARMY_HOST_Y_KEY]
	) - province.position
	
	province.owner_country = (
			game.countries.country_from_id(json_data[PROVINCE_OWNER_ID_KEY])
	)
	
	province.population = Population.new(game)
	province.population.population_size = (
			json_data[PROVINCE_POPULATION_KEY][POPULATION_SIZE_KEY]
	)
	
	for building: Dictionary in json_data[PROVINCE_BUILDINGS_KEY]:
		if building[BUILDING_TYPE_KEY] == BUILDING_TYPE_FORTRESS:
			province.buildings.add(Fortress.new_fortress(game, province))
	
	if (
			game.rules.province_income_option.selected
			== GameRules.ProvinceIncome.POPULATION
	):
		province._income_money = IncomeMoneyPerPopulation.new(
				province.population, game.rules.province_income_per_person.value
		)
	else:
		var base_income: int = 0
		if ParseUtils.dictionary_has_number(
				json_data, PROVINCE_INCOME_MONEY_KEY
		):
			base_income = ParseUtils.dictionary_int(
					json_data, PROVINCE_INCOME_MONEY_KEY
			)
		
		province._income_money = IncomeMoneyConstant.new(base_income)
	
	province.add_component(ArmyReinforcements.new(game, province))
	province.add_component(IncomeEachTurn.new(province, game.turn.turn_changed))
	province.add_component(ProvinceOwnershipUpdate.new(
			province, game.world.armies, game.turn.player_turn_ended
	))
	return province


## Returns true if an error occured, false otherwise.
func _load_armies(json_data: Array, game: Game) -> bool:
	for army_data: Variant in json_data:
		if not army_data is Dictionary:
			error = true
			error_message = "Army data is not a dictionary."
			return true
		var army_dict: Dictionary = army_data
		
		_load_army(army_dict, game)
	return false


# TASK verify & return errors
func _load_army(json_data: Dictionary, game: Game) -> void:
	var movements_made: int = 0
	if json_data.has(ARMY_MOVEMENTS_KEY):
		movements_made = int(json_data[ARMY_MOVEMENTS_KEY])
	
	var _army: Army = Army.quick_setup(
			game,
			json_data[ARMY_ID_KEY],
			json_data[ARMY_SIZE_KEY],
			game.countries.country_from_id(json_data[ARMY_OWNER_ID_KEY]),
			game.world.provinces.province_from_id(
					json_data[ARMY_PROVINCE_ID_KEY]
			),
			movements_made
	)
