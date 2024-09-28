class_name Scenario1
extends Node2D
## This is used for the test map.
## It gathers information from the scene it's in
## to build a new game save file in JSON format.
##
## It's deprecated, but not yet obsolete: this class is useful
## for starting a new game with some randomized elements.
## @deprecated


@export var countries: Array[Country]

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


func as_json(game_rules: GameRules) -> Dictionary:
	var json_data: Dictionary = {}
	
	# Misc.
	json_data["version"] = "1"
	
	# Rules
	json_data["rules"] = RulesToRawDict.new().result(game_rules)
	
	# Players and countries
	var random_country_assignment: Array = range(starting_provinces.size())
	random_country_assignment.shuffle()
	var players_data: Array = []
	var countries_data: Array = []
	for i in starting_provinces.size():
		var player_data: Dictionary = {}
		player_data["id"] = i
		player_data["is_human"] = false
		player_data["playing_country_id"] = random_country_assignment[i]
		players_data.append(player_data)
		
		var country_data: Dictionary = {}
		country_data["id"] = i
		var country: Country = countries[i]
		country_data["country_name"] = country.country_name
		country_data["color"] = country.color.to_html()
		country_data["money"] = game_rules.starting_money.value
		countries_data.append(country_data)
	
	if (
			game_rules.is_diplomacy_presets_enabled()
			and game_rules.starts_with_random_relationship_preset.value
	):
		# Create and populate array with random values
		var random_relationship_preset: Array[Dictionary] = []
		for i in starting_provinces.size():
			random_relationship_preset.append({})
		for i in starting_provinces.size():
			for j in range(i + 1, starting_provinces.size()):
				var random_preset: int = 1 + randi() % 3
				random_relationship_preset[i][j] = random_preset
				random_relationship_preset[j][i] = random_preset
		
		# Apply random values to country data
		for i in starting_provinces.size():
			countries_data[i]["relationships"] = []
			for j in random_relationship_preset.size():
				if i == j:
					continue
				
				countries_data[i]["relationships"].append({
					"recipient_country_id": j,
					"base_data": {
						"preset_id": random_relationship_preset[i][j]
					},
				})
	
	_populate_players_data(players_data, game_rules)
	json_data["players"] = players_data
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
		match game_rules.province_income_option.selected_value():
			GameRules.ProvinceIncome.RANDOM:
				province_data["income_money"] = randi_range(
						game_rules.province_income_random_min.value,
						game_rules.province_income_random_max.value
				)
			GameRules.ProvinceIncome.CONSTANT:
				province_data["income_money"] = (
						game_rules.province_income_constant.value
				)
			GameRules.ProvinceIncome.POPULATION:
				pass
		
		# Population
		var exponential_rng: float = randf() ** 2.0
		var population_size: int = floori(exponential_rng * 1000.0)
		if is_starting_province:
			population_size += game_rules.extra_starting_population.value
		province_data["population"] = {
			"size": population_size,
		}
		
		# Buildings
		var buildings_data: Array = []
		if game_rules.start_with_fortress.value and is_starting_province:
			buildings_data.append({"type": "fortress"})
		province_data["buildings"] = buildings_data
		
		provinces_data.append(province_data)
	world_data["provinces"] = provinces_data
	world_data["armies"] = armies_data
	json_data["world"] = world_data
	
	return json_data


## Takes an [Array] of raw [Dictionary] representing [AIPlayer]s
## and randomizes its data according to the game rules, when applicable.
func _populate_players_data(players_data: Array, rules: GameRules) -> void:
	for element: Variant in players_data:
		if not element is Dictionary:
			continue
		var dictionary := element as Dictionary
		_apply_random_ai_type(dictionary, rules)
		_apply_random_ai_personality_type(dictionary, rules)


## Takes a raw [Dictionary] representing an [AIPlayer]
## and randomizes its AI type.
func _apply_random_ai_type(dictionary: Dictionary, rules: GameRules) -> void:
	# 4.0 Backwards compatibility:
	# When the save data doesn't contain the AI type,
	# it must be assumed to be 0.
	
	if not rules.start_with_random_ai_type.value:
		var default_ai_type: int = rules.default_ai_type.value
		if default_ai_type != 0:
			dictionary.merge({"ai_type": default_ai_type}, true)
		return
	
	var possible_ai_types: Array = PlayerAI.Type.values()
	possible_ai_types.erase(PlayerAI.Type.NONE)
	if possible_ai_types.size() == 0:
		push_error("There is no valid AI type to randomly assign!")
		return
	
	var random_index: int = randi() % possible_ai_types.size()
	var random_ai_type: int = possible_ai_types[random_index]
	
	dictionary.merge({"ai_type": random_ai_type}, true)


## Takes a raw [Dictionary] representing an [AIPlayer]
## and randomizes its AI personality type.
func _apply_random_ai_personality_type(
		dictionary: Dictionary, rules: GameRules
) -> void:
	if not rules.start_with_random_ai_personality.value:
		return
	
	var possible_personality_types: Array[int] = AIPersonality.type_values()
	possible_personality_types.erase(AIPersonality.Type.NONE)
	possible_personality_types.erase(AIPersonality.Type.ACCEPTS_EVERYTHING)
	if possible_personality_types.size() == 0:
		push_error("There is no valid personality type to randomly assign!")
		return
	
	var random_index: int = randi() % possible_personality_types.size()
	var random_personality_type: int = possible_personality_types[random_index]
	
	if (
			random_personality_type
			== rules.default_ai_personality_option.selected_value()
	):
		return
	
	dictionary.merge({"ai_personality_type": random_personality_type}, true)
