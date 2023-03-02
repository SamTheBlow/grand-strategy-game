extends Node2D

export (PackedScene) var country1
export (PackedScene) var country2
export (PackedScene) var country3
export (PackedScene) var army_scene

func get_playable_countries() -> Array:
	return [country1.instance(), country2.instance(), country3.instance()]

func populate_provinces(provinces, player):
	var number_of_players = 3
	var start_province = [provinces[4], provinces[9], provinces[7]]
	for i in number_of_players:
		start_province[i].set_owner_country(player[i])
		var army = army_scene.instance()
		army.owner_country = player[i]
		army.troop_count = 100
		start_province[i].get_node("Armies").add_army(army)
