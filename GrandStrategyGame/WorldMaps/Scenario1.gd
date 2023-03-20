class_name Scenario1
extends Node2D
# Temporary basic scenario for testing


@export var country1: PackedScene
@export var country2: PackedScene
@export var army_scene: PackedScene


func get_playable_countries() -> Array[Country]:
	return [
		country1.instantiate() as Country,
		country2.instantiate() as Country,
	]


func populate_provinces(provinces: Array[Province], countries: Array[Country]):
	var starting_provinces: Array[Province] = [
		provinces[4],
		provinces[9],
	]
	
	var number_of_players: int = 2
	for i in number_of_players:
		starting_provinces[i].set_owner_country(countries[i])
		var army := army_scene.instantiate() as Army
		army.owner_country = countries[i]
		army.troop_count = 100
		var armies := starting_provinces[i].get_node("Armies") as Armies
		armies.add_army(army)
