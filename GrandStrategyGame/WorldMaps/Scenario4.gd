extends Node2D

@export var countries:Array[PackedScene]
@export var army_scene:PackedScene

func get_playable_countries() -> Array:
	var playable_countries:Array = []
	for country in countries:
		playable_countries.append(country.instantiate())
	return playable_countries

func get_new_ai_for(_country:Country) -> PlayerAI:
	return TestAI2.new()

func populate_provinces(provinces, player):
	var number_of_players = 11
	var start_province = [ \
	# UK
	provinces[35 - 1], \
	# France
	provinces[4 - 1], \
	# Germany
	provinces[59 - 1], \
	# Russia
	provinces[29 - 1], \
	# Italy
	provinces[68 - 1], \
	# Poland
	provinces[50 - 1], \
	# Switzerland
	provinces[8 - 1], \
	# Ireland
	provinces[46 - 1], \
	# Austria
	provinces[61 - 1], \
	# Morocco
	provinces[49 - 1], \
	# Algeria
	provinces[48 - 1], \
	]
	for i in number_of_players:
		start_province[i].set_owner_country(player[i])
		var army = army_scene.instantiate()
		army.owner_country = player[i]
		army.troop_count = 1000
		start_province[i].get_node("Armies").add_army(army)
	var number_of_provinces = provinces.size()
	for i in number_of_provinces:
		# Setup populations
		var population = Population.new(10 + randi() % 90)
		population.name = "Population"
		provinces[i].add_component(population)
