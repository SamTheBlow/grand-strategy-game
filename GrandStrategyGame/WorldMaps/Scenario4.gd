class_name Scenario4
extends Node2D


@export var country_scenes: Array[PackedScene]

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


func generate_game_state() -> GameState:
	var countries_data: Array[GameStateData] = []
	var players_data: Array[GameStateData] = []
	var countries: Array[Country] = _countries()
	var number_of_countries: int = countries.size()
	for i in number_of_countries:
		var country_data: Array[GameStateData] = []
		country_data.append(
			GameStateString.new("name", countries[i].country_name)
		)
		country_data.append(
			GameStateInt.new("color", countries[i].color.to_rgba32())
		)
		countries_data.append(GameStateArray.new(str(i), country_data, false))
		
		var player_data: Array[GameStateData] = []
		player_data.append(GameStateString.new("playing_country", str(i)))
		var ai_data: Array[GameStateData] = []
		ai_data.append(GameStateString.new("class_name", "TestAI1"))
		player_data.append(GameStateArray.new("ai", ai_data, false))
		players_data.append(GameStateArray.new(str(i), player_data, true))
	
	var provinces_data: Array[GameStateData] = []
	var number_of_provinces: int = (
		get_parent().get_parent().get_node("Shapes").get_child_count()
	)
	for i in number_of_provinces:
		var province_data: Array[GameStateData] = []
		
		# Owner
		var owner_key: String = "-1"
		var starting_provinces_size: int = starting_provinces.size()
		for j in starting_provinces_size:
			if starting_provinces[j] == i:
				owner_key = str(j)
				break
		province_data.append(GameStateString.new("owner", owner_key))
		
		# Links
		var links_data: Array[GameStateData] = []
		var province_links: PackedInt32Array = (
			get_parent().get_parent().get_node("Shapes") \
			.get_node("Shape" + str(i + 1)) as ProvinceTestData
		).links
		var number_of_links: int = province_links.size()
		for j in number_of_links:
			links_data.append(
				GameStateString.new(str(j), str(province_links[j] - 1))
			)
		province_data.append(GameStateArray.new("links", links_data, true))
		
		# Population
		var population: int = 10 + randi() % 90
		province_data.append(GameStateInt.new("population", population))
		
		# Armies
		var armies_data: Array[GameStateData] = []
		if owner_key != "-1":
			var army_data: Array[GameStateData] = []
			army_data.append(GameStateString.new("owner", owner_key))
			army_data.append(GameStateInt.new("troop_count", 1000))
			
			armies_data.append(GameStateArray.new("0", army_data, false))
		province_data.append(GameStateArray.new("armies", armies_data, true))
		
		provinces_data.append(GameStateArray.new(str(i), province_data, false))
	
	var human_player: String = str(randi() % number_of_countries)
	
	# Build the final product using all the data above
	var game_state: Array[GameStateData] = []
	game_state.append(GameStateArray.new("countries", countries_data, true))
	game_state.append(GameStateArray.new("players", players_data, true))
	game_state.append(GameStateArray.new("provinces", provinces_data, true))
	game_state.append(GameStateString.new("human_player", human_player))
	game_state.append(GameStateInt.new("turn", 1))
	return GameState.new(GameStateArray.new("root", game_state, false))


# We load the country data from the given scenes
func _countries() -> Array[Country]:
	var output: Array[Country] = []
	for country_scene in country_scenes:
		output.append(country_scene.instantiate() as Country)
	return output
