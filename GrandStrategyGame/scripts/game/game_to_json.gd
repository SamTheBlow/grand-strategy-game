class_name GameToJSON
## Class responsible for converting a game into JSON data.


var error: bool = true
var error_message: String = ""
var result: Variant

var _version: String = "1"


func convert_game(game: Game) -> void:
	var json_data: Dictionary = {}
	
	json_data["version"] = _version
	
	# Rules
	var rules_data: Dictionary = {}
	for rule_name in GameRules.RULE_NAMES:
		rules_data[rule_name] = game.rules.get(rule_name)
	json_data["rules"] = rules_data
	
	# Players
	json_data["players"] = PlayersToJSON.new().convert_players(game.players)
	
	# Countries
	var countries_data: Array = []
	for country in game.countries.countries:
		var country_data: Dictionary = {}
		country_data["id"] = country.id
		country_data["country_name"] = country.country_name
		country_data["color"] = country.color.to_html()
		country_data["money"] = country.money
		countries_data.append(country_data)
	json_data["countries"] = countries_data
	
	# World
	var world_data: Dictionary = {}
	
	if game.world is GameWorld2D:
		var world: GameWorld2D = game.world as GameWorld2D
		world_data["limits"] = {
			"top": world.limits.limit_top(),
			"bottom": world.limits.limit_bottom(),
			"left": world.limits.limit_left(),
			"right": world.limits.limit_right(),
		}
	
	# Provinces
	var provinces_data: Array = []
	for province in game.world.provinces.get_provinces():
		var province_data: Dictionary = {
			"id": province.id,
			"position": {"x": province.position.x, "y": province.position.y},
			"owner_country_id": province.owner_country().id,
			"income_money": province.income_money().base_income,
			"position_army_host_x": province.position_army_host.x,
			"position_army_host_y": province.position_army_host.y,
		}
		
		# Links
		var links_json: Array = []
		for link in province.links:
			links_json.append(link.id)
		province_data["links"] = links_json
		
		# Shape
		var shape_vertices := Array(province.province_shape().polygon)
		var shape_vertices_x: Array = []
		var shape_vertices_y: Array = []
		for i in shape_vertices.size():
			shape_vertices_x.append(shape_vertices[i].x)
			shape_vertices_y.append(shape_vertices[i].y)
		province_data["shape"] = {
			"x": shape_vertices_x,
			"y": shape_vertices_y,
		}
		
		# Population
		province_data["population"] = {
			"size": province.population.population_size,
		}
		
		# Buildings
		var buildings_data: Array = []
		for building in province.buildings._buildings:
			# Ugly, but I'll bother when we have more buildings
			buildings_data.append({"type": "fortress"})
		province_data["buildings"] = buildings_data
		
		provinces_data.append(province_data)
	world_data["provinces"] = provinces_data
	
	# Armies
	var armies_data: Array = []
	for army in game.world.armies.armies:
		var army_data: Dictionary = {
			"id": army.id,
			"army_size": army.army_size.current_size(),
			"owner_country_id": army.owner_country().id,
			"province_id": army.province().id
		}
		armies_data.append(army_data)
	world_data["armies"] = armies_data
	
	json_data["world"] = world_data
	
	# Turn
	json_data["turn"] = {
		"turn": game.turn.current_turn(),
		"playing_player_index": game.turn._playing_player_index,
	}
	
	# Success!
	error = false
	result = json_data
