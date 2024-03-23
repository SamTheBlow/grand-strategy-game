class_name GameFromJSON
## Class responsible for loading a game using JSON data.


var error: bool = true
var error_message: String = ""
var result: Game


func load_game(json_data: Variant, game_scene: PackedScene) -> void:
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
	game.init1()
	
	# Rules
	var rules: GameRules = _load_rules(json_dict)
	if not rules:
		return
	game.rules = rules
	
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
	var countries: Countries = _load_countries(json_dict)
	if not countries:
		return
	game.countries = countries
	
	# Players
	if not _load_players(json_dict, game):
		return
	
	# World
	var game_world_2d := game.world_2d_scene.instantiate() as GameWorld2D
	game_world_2d.init()
	game.world = game_world_2d
	# TODO verify & return more errors
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
	var world_limits: WorldLimits = _load_world_limits(limits_data)
	if not world_limits:
		return
	game_world_2d.limits = world_limits
	
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
	
	# Success!
	error = false
	result = game


# Returns null if an error occured
func _load_rules(json_data: Dictionary) -> GameRules:
	var game_rules := GameRules.new()
	
	# Default rules
	var rules_key: String = "rules"
	if not json_data.has(rules_key):
		return game_rules
	
	if not json_data[rules_key] is Dictionary:
		error = true
		error_message = "Rules property is not a dictionary."
		return null
	var rules_data: Dictionary = json_data[rules_key] as Dictionary
	
	for key in GameRules.RULE_NAMES:
		# That's ok, use the default
		if not rules_data.has(key):
			continue
		
		var rule_type: int = typeof(game_rules.get(key))
		
		# Workaround because JSON doesn't support integers
		var data_type: int = typeof(rules_data[key])
		if rule_type == TYPE_INT:
			rule_type = TYPE_FLOAT
		if data_type == TYPE_INT:
			data_type = TYPE_FLOAT
		
		if data_type != rule_type:
			error = true
			error_message = (
					'Rule "' + key
					+ '" is not a ' + type_string(rule_type) + '.'
			)
			return null
		game_rules.set(key, rules_data[key])
	
	return game_rules


func _load_countries(json_data: Dictionary) -> Countries:
	var countries := Countries.new()
	
	var countries_key: String = "countries"
	if not json_data.has(countries_key):
		error = true
		error_message = "No countries found in file."
		return null
	if not json_data[countries_key] is Array:
		error = true
		error_message = "Countries property is not an array."
		return null
	var countries_data: Array = json_data[countries_key]
	
	for country_data: Variant in countries_data:
		if not country_data is Dictionary:
			error = true
			error_message = "Country data is not a dictionary."
			return null
		var country_dict: Dictionary = country_data
		
		var country: Country = _load_country(country_dict)
		if not country:
			return null
		countries.countries.append(country)
	
	return countries


## TODO verify & return errors.
func _load_country(json_data: Dictionary) -> Country:
	var country := Country.new()
	
	country.id = json_data["id"]
	country.country_name = json_data["country_name"]
	country.color = Color(json_data["color"])
	
	if json_data.has("money"):
		country.money = json_data["money"]
	
	return country


func _load_players(json_data: Dictionary, game: Game) -> bool:
	var players := Players.new()
	game.players = players
	
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
		
		var player: Player = _load_player(player_dict, game)
		if not player:
			return false
		players.players.append(player)
	
	return true


# This function requires that game.players is already set
## TODO verify & return errors.
func _load_player(json_data: Dictionary, game: Game) -> Player:
	# AI type
	const number_of_ai_types: int = 2
	var ai_type: int = randi() % number_of_ai_types
	if json_data.has("ai_type"):
		var value_type: int = typeof(json_data["ai_type"])
		# Workaround because JSON doesn't differentiate floats and ints
		if value_type == TYPE_FLOAT:
			value_type = TYPE_INT
		
		if value_type == TYPE_INT:
			ai_type = roundi(json_data["ai_type"])
		else:
			error = true
			error_message = "Player's AI type is not a number."
			return null
	
	var player: Player = Player.new(ai_type)
	player.id = json_data["id"]
	player.playing_country = (
			game.countries.country_from_id(json_data["playing_country_id"])
	)
	if json_data.has("is_human"):
		player.is_human = json_data["is_human"]
	if player.is_human:
		player.default_username = game.players.new_default_username()
	else:
		player.default_username = player.playing_country.country_name
	if json_data.has("username"):
		if not json_data["username"] is String:
			error = true
			error_message = "Player's username property is not a string."
			return null
		player.custom_username = json_data["username"]
	
	return player


## TODO verify & return errors.
func _load_world_limits(json_data: Dictionary) -> WorldLimits:
	var x1: int = json_data["left"]
	var y1: int = json_data["top"]
	var x2: int = json_data["right"]
	var y2: int = json_data["bottom"]
	
	var world_limits := WorldLimits.new()
	world_limits._limits = Rect2i(x1, y1, x2 - x1, y2 - y1)
	return world_limits


## TODO verify & return errors.
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
	province.set_shape(shape)
	
	province.position = (
			Vector2(json_data["position"]["x"], json_data["position"]["y"])
	)
	
	province.set_owner_country(
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


# Returns true if an error occured, false otherwise.
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


## TODO verify & return errors.
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
