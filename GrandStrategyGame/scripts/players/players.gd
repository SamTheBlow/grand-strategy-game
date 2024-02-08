class_name Players


var players: Array[Player]


func player_from_id(id: int) -> Player:
	for player in players:
		if player.id == id:
			return player
	return null
