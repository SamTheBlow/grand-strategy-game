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
	_load_players(json_dict, game)
	if error:
		return

	# We need countries and players to be loaded
	# before we can load the notifications
	_load_game_notifications(json_dict, game)
	if error:
		return

	# World
	var world := GameWorld2D.new()
	game.world = world
	world.armies_of_each_country = (
			ArmiesOfEachCountry.new(game.countries, game.world.armies)
	)
	world.provinces_of_each_country = (
			ProvincesOfEachCountry.new(game.countries, game.world.provinces)
	)
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
		_load_province(province_data, game)
		if error:
			return
	# 2nd loop for links
	for province_data: Dictionary in json_dict[WORLD_KEY][WORLD_PROVINCES_KEY]:
		var province: Province = (
				world.provinces.province_from_id(province_data[PROVINCE_ID_KEY])
		)
		province.links = []
		for link: int in province_data[PROVINCE_LINKS_KEY]:
			province.links.append(world.provinces.province_from_id(link))

	# Armies
	if not ParseUtils.dictionary_has_array(
			json_dict[WORLD_KEY], WORLD_ARMIES_KEY
	):
		json_dict[WORLD_KEY][WORLD_ARMIES_KEY] = []
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

	_load_country_color(json_data, country)
	if error:
		return null

	if json_data.has(COUNTRY_MONEY_KEY):
		country.money = json_data[COUNTRY_MONEY_KEY]

	country.notifications = GameNotifications.new()

	return country


func _load_country_color(json_dict: Dictionary, country: Country) -> void:
	if not ParseUtils.dictionary_has_string(json_dict, COUNTRY_COLOR_KEY):
		error = true
		error_message = (
				"Country data does not contain a color (as HTML string)."
		)
		return

	var color_string: String = json_dict[COUNTRY_COLOR_KEY]

	if not Color.html_is_valid(color_string):
		error = true
		error_message = "Country data contains an invalid color string."
		return

	var country_color: Color = Color.html(color_string)

	# Remove transparency
	country_color.a = 1.0

	country.color = country_color


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


func _load_players(json_data: Dictionary, game: Game) -> void:
	game.game_players = GamePlayers.new()

	if not json_data.has(PLAYERS_KEY):
		error = true
		error_message = "No players found in file."
		return
	if not json_data[PLAYERS_KEY] is Array:
		error = true
		error_message = "Players property is not an array."
		return
	var players_data: Array = json_data[PLAYERS_KEY]

	for player_data: Variant in players_data:
		if not player_data is Dictionary:
			error = true
			error_message = "Player data is not a dictionary."
			return
		var player_dict: Dictionary = player_data

		_load_player(player_dict, game)
		if error:
			return


# TASK verify & return errors
## This function requires that game.game_players is already set
func _load_player(json_data: Dictionary, game: Game) -> void:
	var player := GamePlayer.new()

	# Player ID (mandatory)
	if not ParseUtils.dictionary_has_number(json_data, PLAYER_ID_KEY):
		error = true
		error_message = "Player data doesn't contain an id."
		return
	var id: int = ParseUtils.dictionary_int(json_data, PLAYER_ID_KEY)

	# Verify that the id is valid and available.
	# If not, then the entire data is invalid.
	if not game.game_players.id_system().is_id_available(id):
		error = true
		error_message = (
				"Found an invalid player id."
				+ " Perhaps another player has the same id?"
				+ " (id: " + str(id) + ")"
		)
		return

	# AI type
	var ai_type: int = 0
	if ParseUtils.dictionary_has_number(json_data, PLAYER_AI_TYPE_KEY):
		var loaded_ai_type: int = (
				ParseUtils.dictionary_int(json_data, PLAYER_AI_TYPE_KEY)
		)
		if loaded_ai_type in PlayerAI.Type.values():
			ai_type = loaded_ai_type

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
			return
		player.username = json_data[PLAYER_USERNAME_KEY]
	player.player_ai = PlayerAI.from_type(ai_type)

	var ai_personality_type: int = (
			game.rules.default_ai_personality_option.selected_value()
	)
	if ParseUtils.dictionary_has_number(json_data, PLAYER_AI_PERSONALITY_KEY):
		ai_personality_type = (
				ParseUtils.dictionary_int(json_data, PLAYER_AI_PERSONALITY_KEY)
		)
	var ai_personality: AIPersonality = (
			AIPersonality.from_type(ai_personality_type)
	)
	if ai_personality != null:
		player.player_ai.personality = ai_personality

	game.game_players.add_player(player, id)


# TASK verify & return errors
func _load_world_limits(json_data: Dictionary, limits: WorldLimits) -> bool:
	var x1: int = json_data[WORLD_LIMIT_LEFT_KEY]
	var y1: int = json_data[WORLD_LIMIT_TOP_KEY]
	var x2: int = json_data[WORLD_LIMIT_RIGHT_KEY]
	var y2: int = json_data[WORLD_LIMIT_BOTTOM_KEY]

	limits._limits = Rect2i(x1, y1, x2 - x1, y2 - y1)
	return true


# TASK verify & return errors
## Returns true if an error occured.
func _load_province(json_data: Dictionary, game: Game) -> void:
	var province := Province.new()

	# Province ID (mandatory)
	if not ParseUtils.dictionary_has_number(json_data, PROVINCE_ID_KEY):
		error = true
		error_message = "Province data doesn't contain an id."
		return
	var id: int = ParseUtils.dictionary_int(json_data, PROVINCE_ID_KEY)

	# Verify that the id is valid and available.
	# If not, then the entire data is invalid.
	if not game.world.provinces.id_system().is_id_available(id):
		error = true
		error_message = (
				"Found an invalid province id."
				+ " Perhaps another province has the same id?"
				+ " (id: " + str(id) + ")"
		)
		return

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

	if ParseUtils.dictionary_has_number(json_data, PROVINCE_OWNER_ID_KEY):
		var country_id: int = (
				ParseUtils.dictionary_int(json_data, PROVINCE_OWNER_ID_KEY)
		)
		province.owner_country = game.countries.country_from_id(country_id)

	province.population = Population.new(game)
	province.population.population_size = (
			json_data[PROVINCE_POPULATION_KEY][POPULATION_SIZE_KEY]
	)

	if ParseUtils.dictionary_has_array(json_data, PROVINCE_BUILDINGS_KEY):
		var buildings: Array = json_data[PROVINCE_BUILDINGS_KEY]
		for building: Dictionary in buildings:
			if building[BUILDING_TYPE_KEY] == BUILDING_TYPE_FORTRESS:
				province.buildings.add(Fortress.new_fortress(game, province))

	if (
			game.rules.province_income_option.selected_value()
			== GameRules.ProvinceIncome.POPULATION
	):
		province._income_money = IncomeMoneyPerPopulation.new(
				province.population,
				game.rules.province_income_per_person.value
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

	game.world.provinces.add_province(province, id)
	province.add_component(ArmyReinforcements.new(game, province))
	province.add_component(IncomeEachTurn.new(province, game.turn.turn_changed))
	province.add_component(ProvinceOwnershipUpdate.new(
			province,
			game.world.armies_in_each_province.dictionary[province],
			game.turn.player_turn_ended
	))


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


func _load_army(json_data: Dictionary, game: Game) -> void:
	# Army ID (mandatory)
	if not ParseUtils.dictionary_has_number(json_data, ARMY_ID_KEY):
		error = true
		error_message = "Army data doesn't contain an id."
		return
	var id: int = ParseUtils.dictionary_int(json_data, ARMY_ID_KEY)

	# Verify that the id is valid and available.
	# If not, then the entire data is invalid.
	if not game.world.armies.id_system().is_id_available(id):
		error = true
		error_message = (
				"Found an invalid army id."
				+ " Perhaps another army has the same id?"
				+ " (id: " + str(id) + ")"
		)
		return

	# Army size (optional, defaults to 1)
	var army_size: int = 1
	if ParseUtils.dictionary_has_number(json_data, ARMY_SIZE_KEY):
		army_size = ParseUtils.dictionary_int(json_data, ARMY_SIZE_KEY)

	# Owner country (mandatory)
	if not ParseUtils.dictionary_has_number(json_data, ARMY_OWNER_ID_KEY):
		error = true
		error_message = "Army data doesn't contain an owner country id."
		return
	var owner_country_id: int = (
			ParseUtils.dictionary_int(json_data, ARMY_OWNER_ID_KEY)
	)
	var owner_country: Country = (
			game.countries.country_from_id(owner_country_id)
	)
	if owner_country == null:
		error = true
		error_message = (
				"Army data contains an invalid owner country id ("
				+ str(owner_country_id) + ")."
		)
		return

	# Province (mandatory)
	if not ParseUtils.dictionary_has_number(json_data, ARMY_PROVINCE_ID_KEY):
		error = true
		error_message = "Army data doesn't contain a province id."
		return
	var province_id: int = (
			ParseUtils.dictionary_int(json_data, ARMY_PROVINCE_ID_KEY)
	)
	var province: Province = game.world.provinces.province_from_id(province_id)
	if province == null:
		error = true
		error_message = (
				"Army data contains an invalid province id ("
				+ str(province_id) + ")."
		)
		return

	# Movements made (optional, defaults to 0)
	var movements_made: int = 0
	if ParseUtils.dictionary_has_number(json_data, ARMY_MOVEMENTS_KEY):
		movements_made = (
				ParseUtils.dictionary_int(json_data, ARMY_MOVEMENTS_KEY)
		)

	var _army: Army = Army.quick_setup(
			game, army_size, owner_country, province, id, movements_made
	)
