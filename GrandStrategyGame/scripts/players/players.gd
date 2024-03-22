class_name Players
## Class responsible for some group of players.


var players: Array[Player]


func player_from_id(id: int) -> Player:
	for player in players:
		if player.id == id:
			return player
	return null


func number_of_humans() -> int:
	var output: int = 0
	
	for player in players:
		if player.is_human:
			output += 1
	
	return output


## Provides the default username for a potential new player.
## For example, if there are already players named "Player 1" and "Player 2",
## then this function will return "Player 3".
func new_default_username() -> String:
	var player_number: int = 1
	while true:
		var is_number_already_used: bool = false
		for player in players:
			if player.default_username == "Player " + str(player_number):
				is_number_already_used = true
				player_number += 1
				break
		if not is_number_already_used:
			break
	return "Player " + str(player_number)
