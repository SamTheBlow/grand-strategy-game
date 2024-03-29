class_name Scenario1
extends Node2D


@export var countries: Array[Country]
@export var world_scene: PackedScene
@export var province_scene: PackedScene
@export var army_scene: PackedScene

var starting_provinces: Array[int] = [
	# UK
	35 - 1,
	# France
	4 - 1,
	# Germany
	59 - 1,
	# Russia
	29 - 1,
	# Italy
	68 - 1,
	# Poland
	50 - 1,
	# Switzerland
	8 - 1,
	# Ireland
	46 - 1,
	# Austria
	61 - 1,
	# Morocco
	49 - 1,
	# Algeria
	48 - 1,
]


func as_json(game_rules: GameRules, players: Players) -> Dictionary:
	var json_data: Dictionary = {}
	
	# Misc.
	json_data["version"] = "1"
	
	# Rules
	var rules_data: Dictionary = {}
	for rule_name in GameRules.RULE_NAMES:
		rules_data[rule_name] = game_rules.get(rule_name)
	json_data["rules"] = rules_data
	
	# Players and countries
	# The player ID pool is to ensure that all player IDs are unique
	# This code is probably a bit slow when there's tons of players...
	var random_country_assignment: Array = range(starting_provinces.size())
	random_country_assignment.shuffle()
	var players_data: Array = PlayersToJSON.new().convert_players(players)
	var player_id_pool: Array[int] = []
	for player_data: Variant in players_data:
		player_id_pool.append(player_data["id"])
	players_data.resize(starting_provinces.size())
	
	var ordered_players_data: Array = []
	var countries_data: Array = []
	for i in starting_provinces.size():
		var player_index := int(random_country_assignment[i])
		if not players_data[player_index]:
			var player_data: Dictionary = {}
			
			var unique_player_id: int = 0
			while player_id_pool.has(unique_player_id):
				unique_player_id += 1
			player_id_pool.append(unique_player_id)
			
			player_data["id"] = unique_player_id
			players_data[player_index] = player_data
		players_data[player_index]["playing_country_id"] = i
		ordered_players_data.append(players_data[player_index])
		
		var country_data: Dictionary = {}
		country_data["id"] = i
		var country: Country = countries[i]
		country_data["country_name"] = country.country_name
		country_data["color"] = country.color.to_html()
		country_data["money"] = game_rules.starting_money
		countries_data.append(country_data)
	json_data["players"] = ordered_players_data
	json_data["countries"] = countries_data
	
	# World
	var world_data: Dictionary = {}
	
	# World limits
	var limits: WorldLimits = WorldLimits.from_rect2i(
			Rect2i(Vector2i.ZERO, (%WorldSize as Marker2D).position)
	)
	world_data["limits"] = {
		"top": limits.limit_top(),
		"bottom": limits.limit_bottom(),
		"left": limits.limit_left(),
		"right": limits.limit_right(),
	}
	
	# Provinces
	var provinces_data: Array = []
	var armies_data: Array = []
	var number_of_provinces: int = %Shapes.get_child_count()
	for i in number_of_provinces:
		var shape := %Shapes.get_node("Shape" + str(i + 1)) as ProvinceTestData
		
		var province_data: Dictionary = {}
		province_data["id"] = i
		province_data["position"] = {
			"x": shape.position.x,
			"y": shape.position.y
		}
		
		# Owner country
		var is_starting_province: bool = false
		var starting_province_country_id: int = -1
		for j in starting_provinces.size():
			if starting_provinces[j] == i:
				is_starting_province = true
				starting_province_country_id = j
				break
		province_data["owner_country_id"] = starting_province_country_id
		
		# Position army host
		var army_host_node := shape.get_node("ArmyHost") as Node2D
		var position_army_host: Vector2 = army_host_node.global_position
		province_data["position_army_host_x"] = position_army_host.x
		province_data["position_army_host_y"] = position_army_host.y
		
		# Links
		var links_json: Array = []
		var province_links: PackedInt32Array = shape.links
		for j in province_links.size():
			links_json.append(province_links[j] - 1)
		province_data["links"] = links_json
		
		# Shape
		var shape_vertices := Array(shape.polygon)
		var shape_vertices_x: Array = []
		var shape_vertices_y: Array = []
		for j in shape_vertices.size():
			shape_vertices_x.append(shape_vertices[j].x)
			shape_vertices_y.append(shape_vertices[j].y)
		province_data["shape"] = {
			"x": shape_vertices_x,
			"y": shape_vertices_y,
		}
		
		# Armies
		if is_starting_province:
			var army_data: Dictionary = {
				"id": starting_province_country_id,
				"army_size": 1000,
				"owner_country_id": starting_province_country_id,
				"province_id": i,
			}
			armies_data.append(army_data)
		
		# Income
		match game_rules.province_income_option:
			GameRules.ProvinceIncome.RANDOM:
				province_data["income_money"] = randi_range(
						game_rules.province_income_random_min,
						game_rules.province_income_random_max
				)
			GameRules.ProvinceIncome.CONSTANT:
				province_data["income_money"] = (
						game_rules.province_income_constant
				)
			GameRules.ProvinceIncome.POPULATION:
				pass
		
		# Population
		var exponential_rng: float = randf() ** 2.0
		var population_size: int = floori(exponential_rng * 1000.0)
		if is_starting_province:
			population_size += game_rules.extra_starting_population
		province_data["population"] = {
			"size": population_size,
		}
		
		# Buildings
		var buildings_data: Array = []
		if game_rules.start_with_fortress and is_starting_province:
			buildings_data.append({"type": "fortress"})
		province_data["buildings"] = buildings_data
		
		provinces_data.append(province_data)
	world_data["provinces"] = provinces_data
	world_data["armies"] = armies_data
	json_data["world"] = world_data
	
	return json_data
