class_name PlayersToJSON
## Class responsible for converting players into JSON data.


func convert_players(players: Players) -> Array:
	var players_data: Array = []
	for player in players.players:
		var player_data: Dictionary = {}
		player_data["id"] = player.id
		if player.playing_country:
			player_data["playing_country_id"] = player.playing_country.id
		player_data["is_human"] = player.is_human
		if player.custom_username != "":
			player_data["username"] = player.custom_username
		player_data["ai_type"] = player._ai_type
		players_data.append(player_data)
	
	return players_data
