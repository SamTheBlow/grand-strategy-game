class_name PlayersToJSON
## Class responsible for converting players into JSON data.


func convert_players(players: GamePlayers) -> Array:
	var players_data: Array = []
	for player in players.list():
		var player_data: Dictionary = {}
		player_data["id"] = player.id
		if player.playing_country:
			player_data["playing_country_id"] = player.playing_country.id
		player_data["is_human"] = player.is_human
		player_data["username"] = player.username
		player_data["ai_type"] = player.ai_type()
		players_data.append(player_data)
	
	return players_data
