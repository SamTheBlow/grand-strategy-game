extends Node2D

export (PackedScene) var country1
export (PackedScene) var country2
export (PackedScene) var country3
export (PackedScene) var army_scene
export (PackedScene) var fortress_scene

func get_playable_countries() -> Array:
	return [country1.instance(), country2.instance(), country3.instance()]

func get_new_ai_for(_country:Country) -> PlayerAI:
	if _country.country_name == "Player 2":
		return TestAI1.new()
	else:
		return TestAI2.new()

func populate_provinces(provinces, players):
	var number_of_players = 3
	var start_province = [provinces[0], provinces[1], provinces[2]]
	for i in number_of_players:
		start_province[i].set_owner_country(players[i])
		var army = army_scene.instance()
		army.owner_country = players[i]
		army.troop_count = 1000
		start_province[i].get_node("Armies").add_army(army)
	var number_of_provinces = provinces.size()
	for i in number_of_provinces:
		# Setup fortresses
		var fortress = fortress_scene.instance()
		var fortress_position = get_parent().get_parent().get_node("FortressPositions/Fort4").position - provinces[i].global_position
		var fortress_built = false
		if i == 3:
			fortress_built = true
		fortress.init(fortress_built, fortress_position)
		provinces[i].add_component(fortress)
		# Setup populations
		var population = Population.new(10 + randi() % 90)
		population.name = "Population"
		provinces[i].add_component(population)
