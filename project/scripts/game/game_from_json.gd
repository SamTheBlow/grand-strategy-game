class_name GameFromJSON
## Class responsible for loading a game using JSON data.
# TODO tons of stuff in here needs to verify & return errors


var error: bool = false
var error_message: String = ""
var result: Game


func load_game(json_data: Variant, game_scene: PackedScene) -> void:
	error = false
	error_message = ""
	
	if not json_data is Dictionary:
		error = true
		error_message = "JSON data's root is not a dictionary."
		return
	var json_dict: Dictionary = json_data
	
	# Check version
	if not json_dict.has("version"):
		error = true
		error_message = "JSON data doesn't have a \"version\" property."
		return
	var version: String = json_dict["version"]
	if version != "1":
		error = true
		error_message = "Save data is from an unrecognized version."
		return
	
	# Loading begins!
	var game := game_scene.instantiate() as Game
	game.init()
	
	# Rules
	game.rules = RulesFromDict.new().result(json_dict["rules"] as Dictionary)
	
	# Turn
	var turn_key: String = "turn"
	if json_dict.has(turn_key):
		if not json_dict[turn_key] is Dictionary:
			error = true
			error_message = "Turn property (in root) is not a dictionary."
			return
		
		# Workaround because JSON doesn't differentiate between int and float
		var value_type: int = typeof(json_dict[turn_key]["turn"])
		if value_type == TYPE_INT:
			value_type = TYPE_FLOAT
		if value_type != TYPE_FLOAT:
			error = true
			error_message = "Turn property is not a number."
			return
		
		value_type = typeof(json_dict[turn_key]["playing_player_index"])
		if value_type == TYPE_INT:
			value_type = TYPE_FLOAT
		if value_type != TYPE_FLOAT:
			error = true
			error_message = "Playing player index is not a number."
			return
		
		game.setup_turn(
				roundi(json_dict[turn_key]["turn"]),
				roundi(json_dict[turn_key]["playing_player_index"])
		)
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
	var game_world_2d := game.world_2d_scene.instantiate() as GameWorld2D
	game_world_2d.init(game)
	game.world = game_world_2d
	# TASK verify & return errors
	if not (
			json_dict.has("world")
			and json_dict["world"].has("limits")
			and json_dict["world"].has("provinces")
	):
		error = true
		error_message = "World data is missing."
		return
	
	# Camera limits
	var limits_data: Dictionary = json_dict["world"]["limits"]
	if not _load_world_limits(limits_data, game_world_2d.limits):
		return
	
	# Provinces
	for province_data: Dictionary in json_dict["world"]["provinces"]:
		var province: Province = _load_province(province_data, game)
		if not province:
			return
		game_world_2d.provinces.add_province(province)
	# 2nd loop for links
	for province_data: Dictionary in json_dict["world"]["provinces"]:
		var province: Province = (
				game_world_2d.provinces.province_from_id(province_data["id"])
		)
		province.links = []
		for link: int in province_data["links"]:
			province.links.append(
					game_world_2d.provinces.province_from_id(link)
			)
	
	# Armies
	var armies_error: bool = _load_armies(json_dict["world"]["armies"], game)
	if armies_error:
		return
	
	# Auto arrows
	# We have to load these after the provinces
	_load_auto_arrows(json_dict, game)
	
	# Success!
	result = game


func _loaded_countries(json_data: Dictionary) -> Array[Country]:
	var countries: Array[Country] = []
	
	var countries_key: String = "countries"
	if not json_data.has(countries_key):
		error = true
		error_message = "No countries found in file."
		return []
	if not json_data[countries_key] is Array:
		error = true
		error_message = "Countries property is not an array."
		return []
	var countries_data: Array = json_data[countries_key]
	
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
	
	country.id = json_data["id"]
	country.country_name = json_data["country_name"]
	country.color = Color(json_data["color"])
	
	if json_data.has("money"):
		country.money = json_data["money"]
	
	country.notifications = GameNotifications.new()
	
	return country


func _load_diplomacy_relationships(json_dict: Dictionary, game: Game) -> void:
	# TODO DRY. a lot of copy/paste from _load_auto_arrows()
	if not json_dict.has("countries"):
		return
	
	var countries_data: Variant = json_dict["countries"]
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
				country_dict.has("relationships")
				and country_dict["relationships"] is Array
		):
			continue
		
		var country: Country = country_list[i]
		var relationships_data := country_dict["relationships"] as Array
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
	# TODO DRY. a lot of copy/paste from _load_auto_arrows()
	if not json_dict.has("countries"):
		return
	
	var countries_data: Variant = json_dict["countries"]
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
				country_dict.has("notifications")
				and country_dict["notifications"] is Array
		):
			continue
		var notifications_array := country_dict["notifications"] as Array
		
		var country: Country = country_list[i]
		
		var notifications_from_raw := GameNotificationsFromRaw.new()
		notifications_from_raw.apply(game, country, notifications_array)
		if notifications_from_raw.error:
			continue
		
		country.notifications = notifications_from_raw.result


func _load_auto_arrows(json_dict: Dictionary, game: Game) -> void:
	if not json_dict.has("countries"):
		return
	
	var countries_data: Variant = json_dict["countries"]
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
		
		if not country_dict.has("auto_arrows"):
			continue
		
		country_list[i].auto_arrows = (
				AutoArrowsFromJSON.new()
				.result(game, country_dict["auto_arrows"])
		)


func _load_players(json_data: Dictionary, game: Game) -> bool:
	game.game_players = GamePlayers.new()
	
	var players_key: String = "players"
	if not json_data.has(players_key):
		error = true
		error_message = "No players found in file."
		return false
	if not json_data[players_key] is Array:
		error = true
		error_message = "Players property is not an array."
		return false
	var players_data: Array = json_data[players_key]
	
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


## This function requires that game.game_players is already set
# TASK verify & return errors
func _load_player(json_data: Dictionary, game: Game) -> GamePlayer:
	# AI type
	var ai_type: int = 0
	if json_data.has("ai_type"):
		var value_type: int = typeof(json_data["ai_type"])
		# Workaround because JSON doesn't differentiate floats and ints
		if value_type == TYPE_FLOAT:
			value_type = TYPE_INT
		
		if value_type == TYPE_INT:
			var loaded_ai_type: int = roundi(json_data["ai_type"])
			# If the AI type is invalid, default to the dummy AI
			if PlayerAI.Type.find_key(loaded_ai_type):
				ai_type = loaded_ai_type
		else:
			error = true
			error_message = "Player's AI type is not a number."
			return null
	
	var player: GamePlayer = GamePlayer.new()
	player.id = json_data["id"]
	# The player is a spectator if there is no country id,
	# of if the country id is a negative number
	if json_data.has("playing_country_id"):
		var country_id: int = json_data["playing_country_id"]
		if country_id >= 0:
			player.playing_country = (
					game.countries.country_from_id(country_id)
			)
	if json_data.has("is_human"):
		player.is_human = json_data["is_human"]
	if json_data.has("username"):
		if not json_data["username"] is String:
			error = true
			error_message = "Player's username property is not a string."
			return null
		player.username = json_data["username"]
	if json_data.has("human_id"):
		player.player_human_id = json_data["human_id"]
	player.player_ai = PlayerAI.from_type(ai_type)
	
	var ai_personality_id: int = (
			game.rules.default_ai_personality_option.selected
	)
	if json_data.has("ai_personality_type"):
		var personality_data: Variant = json_data["ai_personality_type"]
		if typeof(personality_data) in [TYPE_INT, TYPE_FLOAT]:
			ai_personality_id = roundi(personality_data)
	var ai_personality: AIPersonality = (
			AIPersonality.from_type(ai_personality_id)
	)
	if ai_personality != null:
		player.player_ai.personality = ai_personality
	
	return player


# TASK verify & return errors
func _load_world_limits(json_data: Dictionary, limits: WorldLimits) -> bool:
	var x1: int = json_data["left"]
	var y1: int = json_data["top"]
	var x2: int = json_data["right"]
	var y2: int = json_data["bottom"]
	
	limits._limits = Rect2i(x1, y1, x2 - x1, y2 - y1)
	return true


# TASK verify & return errors
func _load_province(json_data: Dictionary, game: Game) -> Province:
	var province := game.province_scene.instantiate() as Province
	province.game = game
	province.id = json_data["id"]
	
	province.position_army_host = Vector2(
			json_data["position_army_host_x"],
			json_data["position_army_host_y"]
	)
	
	province.init()
	
	var shape: PackedVector2Array = []
	for i in (json_data["shape"]["x"] as Array).size():
		shape.append(Vector2(
				json_data["shape"]["x"][i], json_data["shape"]["y"][i]
		))
	province.polygon = shape
	
	province.position = (
			Vector2(json_data["position"]["x"], json_data["position"]["y"])
	)
	
	province.owner_country = (
			game.countries.country_from_id(json_data["owner_country_id"])
	)
	
	province.population = Population.new(game)
	province.population.population_size = json_data["population"]["size"]
	
	for building: Dictionary in json_data["buildings"]:
		if building["type"] == "fortress":
			var fortress: Fortress = Fortress.new_fortress(
					game, province
			)
			fortress.add_visuals()
			province.buildings.add(fortress)
	
	var base_income: int = 0
	if json_data.has("income_money"):
		base_income = json_data["income_money"]
	province._income_money = IncomeMoney.new(base_income, province)
	
	return province


## Returns true if an error occured, false otherwise.
func _load_armies(json_data: Array, game: Game) -> bool:
	game.world.armies = Armies.new()
	
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
	if json_data.has("number_of_movements_made"):
		movements_made = int(json_data["number_of_movements_made"])
	
	var _army: Army = Army.quick_setup(
			game,
			json_data["id"],
			json_data["army_size"],
			game.countries.country_from_id(json_data["owner_country_id"]),
			game.world.provinces.province_from_id(json_data["province_id"]),
			movements_made
	)
