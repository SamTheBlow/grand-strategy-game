class_name GameStateFromJSON
## Loads a game state from given JSON data.


var _json_data: Dictionary

## Contains the built game state
var game_state: GameState


func _init(json_data: Dictionary) -> void:
	_json_data = json_data


## Returns an Error (OK if it worked, otherwise ERR_PARSE_ERROR)
func build() -> int:
	var result := GameState.new()
	result.name = "GameState"
	
	# Rules
	if not _json_data.has("rules"):
		return ERR_PARSE_ERROR
	result.rules = GameRules.from_json(_json_data["rules"])
	
	# Countries
	result.countries = Countries.new()
	result.countries.name = "Countries"
	if not _json_data.has("countries"):
		return ERR_PARSE_ERROR
	for country_data in _json_data["countries"]:
		result.countries.add_country(Country.from_json(country_data))
	result.add_child(result.countries)
	
	# Players
	result.players = Players.new()
	result.players.name = "Players"
	if not _json_data.has("players"):
		return ERR_PARSE_ERROR
	for player_data in _json_data["players"]:
		result.players.add_player(
				Player.from_json(player_data, result.countries)
		)
	result.add_child(result.players)
	
	# World
	var game_world_2d := preload("res://scenes/world_2d.tscn").instantiate() as GameWorld2D
	game_world_2d.init()
	if not (
			_json_data.has("world")
			and _json_data["world"].has("limits")
			and _json_data["world"].has("provinces")
	):
		return ERR_PARSE_ERROR
	
	# Camera limits
	game_world_2d.limits = WorldLimits.from_json(_json_data["world"]["limits"])
	
	# Provinces
	for province_data in _json_data["world"]["provinces"]:
		game_world_2d.provinces.add_province(
				Province.from_json(province_data, result)
		)
	# 2nd loop for links
	for province_data in _json_data["world"]["provinces"]:
		var province: Province = (
				game_world_2d.provinces.province_from_id(province_data["id"])
		)
		province.links = []
		for link in province_data["links"]:
			province.links.append(
					game_world_2d.provinces.province_from_id(link)
			)
	result.world = game_world_2d
	result.add_child(result.world)
	
	# Turn
	if _json_data.has("turn"):
		result.setup_turn(_json_data["turn"])
	else:
		result.setup_turn()
	
	game_state = result
	return OK
