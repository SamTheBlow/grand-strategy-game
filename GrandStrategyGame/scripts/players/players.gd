class_name Players


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
