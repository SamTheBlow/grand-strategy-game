extends Node2D

@export var country1:PackedScene
@export var country2:PackedScene
@export var country3:PackedScene
@export var army_scene:PackedScene
@export var fortress_scene:PackedScene

func get_playable_countries() -> Array:
	return [country1.instantiate(), country2.instantiate(), country3.instantiate()]

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
		var army = army_scene.instantiate()
		army.owner_country = players[i]
		army.troop_count = 1000
		start_province[i].get_node("Armies").add_army(army)
	var number_of_provinces = provinces.size()
	for i in number_of_provinces:
		# Setup fortresses
		var fortress = fortress_scene.instantiate()
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
