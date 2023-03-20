class_name Scenario4
extends Node2D


@export var country_scenes: Array[PackedScene]
@export var army_scene: PackedScene


func get_playable_countries() -> Array[Country]:
	var playable_countries: Array[Country] = []
	for country_scene in country_scenes:
		playable_countries.append(country_scene.instantiate() as Country)
	return playable_countries


func get_new_ai_for(_country: Country) -> PlayerAI:
	return TestAI2.new()


func populate_provinces(provinces: Array[Province], countries: Array[Country]):
	var starting_provinces: Array[Province] = [
		# UK
		provinces[35 - 1],
		# France
		provinces[4 - 1],
		# Germany
		provinces[59 - 1],
		# Russia
		provinces[29 - 1],
		# Italy
		provinces[68 - 1],
		# Poland
		provinces[50 - 1],
		# Switzerland
		provinces[8 - 1],
		# Ireland
		provinces[46 - 1],
		# Austria
		provinces[61 - 1],
		# Morocco
		provinces[49 - 1],
		# Algeria
		provinces[48 - 1],
	]
	
	var number_of_players: int = 11
	for i in number_of_players:
		starting_provinces[i].set_owner_country(countries[i])
		var army := army_scene.instantiate() as Army
		army.owner_country = countries[i]
		army.troop_count = 1000
		var armies := starting_provinces[i].get_node("Armies") as Armies
		armies.add_army(army)
	
	var number_of_provinces: int = provinces.size()
	for i in number_of_provinces:
		# Setup populations
		var population := Population.new(10 + randi() % 90)
		population.name = "Population"
		provinces[i].add_component(population)
