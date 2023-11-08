class_name Players
extends Node
## Do not use add_child() to add players: use add_player() instead


var players: Array[Player]


func add_player(player: Player) -> void:
	players.append(player)
	add_child(player)


func player_from_id(id: int) -> Player:
	for player in players:
		if player.id == id:
			return player
	return null


func as_json() -> Array:
	var array: Array = []
	for player in players:
		array.append(player.as_json())
	return array
