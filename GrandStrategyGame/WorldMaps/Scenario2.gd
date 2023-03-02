extends Node2D

@export var country1:PackedScene
@export var country2:PackedScene
@export var country3:PackedScene
@export var army_scene:PackedScene

func get_playable_countries() -> Array:
	return [country1.instantiate(), country2.instantiate(), country3.instantiate()]

func populate_provinces(provinces, player):
	var number_of_players = 3
	var start_province = [provinces[4], provinces[9], provinces[7]]
	for i in number_of_players:
		start_province[i].set_owner_country(player[i])
		var army = army_scene.instantiate()
		army.owner_country = player[i]
		army.troop_count = 100
		start_province[i].get_node("Armies").add_army(army)
