class_name Players
## Class responsible for some group of players.


var players: Array[Player]


## You don't have to use this method to add a player, but,
## it makes things easier by automatically assigning the player a unique id.
func add_player(player: Player) -> void:
	player.id = new_unique_id()
	players.append(player)


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
			if player.username() == "Player " + str(player_number):
				is_number_already_used = true
				player_number += 1
				break
		if not is_number_already_used:
			break
	return "Player " + str(player_number)


## Provides a new unique id that none of the players are using.
## The id will be as small as possible (0 or higher).
func new_unique_id() -> int:
	var new_id: int = 0
	var id_is_not_unique: bool = true
	while id_is_not_unique:
		id_is_not_unique = false
		for player in players:
			if player.id == new_id:
				id_is_not_unique = true
				new_id += 1
				break
	return new_id
