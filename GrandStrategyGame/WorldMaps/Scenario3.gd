class_name Scenario3
extends Node2D
# Temporary basic scenario for testing


@export var country1: PackedScene
@export var country2: PackedScene
@export var country3: PackedScene
@export var army_scene: PackedScene
@export var fortress_scene: PackedScene


func get_playable_countries() -> Array[Country]:
	return [
		country1.instantiate() as Country,
		country2.instantiate() as Country,
		country3.instantiate() as Country,
	]


func get_new_ai_for(country: Country) -> PlayerAI:
	if country.country_name == "Player 2":
		return TestAI1.new()
	else:
		return TestAI2.new()


func populate_provinces(provinces: Array[Province], countries: Array[Country]):
	var starting_provinces: Array[Province] = [
		provinces[0],
		provinces[1],
		provinces[2],
	]
	
	var number_of_players: int = 3
	for i in number_of_players:
		starting_provinces[i].set_owner_country(countries[i])
		var army := army_scene.instantiate() as Army
		army.owner_country = countries[i]
		army.troop_count = 1000
		var armies := starting_provinces[i].get_node("Armies") as Armies
		armies.add_army(army)
	
	var number_of_provinces: int = provinces.size()
	for i in number_of_provinces:
		# Setup fortresses
		var fortress := fortress_scene.instantiate() as Fortress
		var fortress_position: Vector2 = (get_parent().get_parent().get_node(
			"Shapes/Shape" + str(i + 1) + "/Fortress"
		) as Node2D).position
		var fortress_built: bool = false
		if i == 3:
			fortress_built = true
		fortress.init(fortress_built, fortress_position)
		provinces[i].add_component(fortress)
		
		# Setup populations
		var population := Population.new(10 + randi() % 90)
		population.name = "Population"
		provinces[i].add_component(population)
