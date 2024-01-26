class_name Scenario1
extends Node2D


@export var country_scenes: Array[PackedScene]
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

var _number_of_countries: int = 11

var human_player: int = randi() % _number_of_countries


func generate_game_state(
		game_mediator: GameMediator,
		game_rules: GameRules
) -> GameState:
	var game_state := GameState.new()
	game_state.name = "GameState"
	game_state.rules = game_rules
	
	# Build the countries and the players
	var countries := Countries.new()
	countries.name = "Countries"
	var players := Players.new()
	players.name = "Players"
	
	for i in country_scenes.size():
		var country := country_scenes[i].instantiate() as Country
		country.name = str(i)
		country.id = i
		
		var player: Player
		if i == human_player:
			player = PlayerHuman.new()
		else:
			player = TestAI1.new()
		player.name = str(i)
		player.id = i
		player.playing_country = country
		
		countries.add_country(country)
		players.add_player(player)
	
	game_state.countries = countries
	game_state.add_child(countries)
	game_state.players = players
	game_state.add_child(players)
	
	# Build the world
	var world := world_scene.instantiate() as GameWorld2D
	world.init()
	
	# Set the camera's limits
	var world_size_node := %WorldSize as Marker2D
	world.limits = WorldLimits.from_rect2i(
			Rect2i(Vector2i.ZERO, world_size_node.position)
	)
	
	# Provinces
	var number_of_provinces: int = %Shapes.get_child_count()
	for i in number_of_provinces:
		var shape := %Shapes.get_node("Shape" + str(i + 1)) as ProvinceTestData
		
		var province := province_scene.instantiate() as Province
		province._game_mediator = game_mediator
		province.name = str(i)
		province.id = i
		province.set_shape(shape.polygon)
		province.position = shape.position
		
		var is_starting_province: bool = false
		var starting_province_country_id: int
		for j in starting_provinces.size():
			if starting_provinces[j] == i:
				is_starting_province = true
				starting_province_country_id = j
				break
		
		# Owner
		if is_starting_province:
			province.set_owner_country(
					countries.country_from_id(starting_province_country_id)
			)
		
		# Population
		var population_size: int = 10 + randi() % 90
		var population_growth: bool = game_rules.population_growth
		province.setup_population(population_size, population_growth)
		
		# Armies
		var army_host_node := shape.get_node("ArmyHost") as Node2D
		var position_army_host: Vector2 = army_host_node.global_position
		province.setup_armies(position_army_host)
		
		if province.has_owner_country():
			var army := army_scene.instantiate() as Army
			army._game_mediator = game_mediator
			army.id = 0
			army.set_owner_country(province.owner_country())
			army.setup(1000)
			
			province.armies.add_army(army)
		
		# Buildings
		province.setup_buildings()
		if game_rules.fortresses and is_starting_province:
			var fortress: Fortress = Fortress.new_fortress(
					game_mediator, province
			)
			fortress.add_visuals(
					preload("res://scenes/fortress.tscn") as PackedScene
			)
			province.buildings.add(fortress)
		
		world.provinces.add_province(province)
	
	# Second loop (we need all the provinces to be created beforehand)
	for i in number_of_provinces:
		var province: Province = world.provinces.province_from_id(i)
		var shape := %Shapes.get_node("Shape" + str(i + 1)) as ProvinceTestData
		
		# Links
		province.links = []
		var province_links: PackedInt32Array = shape.links
		var number_of_links: int = province_links.size()
		for j in number_of_links:
			var id: int = province_links[j] - 1
			province.links.append(world.provinces.province_from_id(id))
	
	game_state.world = world
	game_state.add_child(world)
	
	game_state.setup_turn()
	
	return game_state
