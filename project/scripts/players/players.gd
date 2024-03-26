class_name Players
## Class responsible for some group of players.


signal player_added(player: Player)
signal player_removed(player: Player)

var _list: Array[Player]


## Appends a player at the bottom of the list.
func add_player(player: Player) -> void:
	_list.append(player)
	player_added.emit(player)


func remove_player(player: Player) -> void:
	if _list.has(player):
		_list.erase(player)
		player_removed.emit(player)
	else:
		print_debug("Tried to remove a player, but it isn't on the list!")


## If there is no player with given id, returns [code]null[/code].
func player_from_id(id: int) -> Player:
	for player in _list:
		if player.id == id:
			return player
	return null


## Returns a copy of this list.
func list() -> Array[Player]:
	return _list.duplicate()


## Returns the number of players on the list.
func size() -> int:
	return _list.size()


## Returns the given player's position on the list.
## If the player is not on the list, returns -1.
func index_of(player: Player) -> int:
	return _list.find(player)


## Returns the player at given index position.
## If the index is not in range, returns null.
func player_from_index(index: int) -> Player:
	if index < 0 or index >= _list.size():
		return null
	return _list[index]


func number_of_humans() -> int:
	var output: int = 0
	for player in _list:
		if player.is_human:
			output += 1
	return output


## Provides the default username for a potential new player.
## For example, if there are already players named "Player 1" and "Player 2",
## then this function will return "Player 3".
func new_default_username() -> String:
	var player_number: int = 1
	var is_invalid_number: bool = true
	while is_invalid_number:
		is_invalid_number = false
		for player in _list:
			if player.username() == "Player " + str(player_number):
				is_invalid_number = true
				player_number += 1
				break
	return "Player " + str(player_number)


## Provides a new unique id that is not used by any player in the list.
## The id will be as small as possible (0 or higher).
func new_unique_id() -> int:
	var new_id: int = 0
	var id_is_not_unique: bool = true
	while id_is_not_unique:
		id_is_not_unique = false
		for player in _list:
			if player.id == new_id:
				id_is_not_unique = true
				new_id += 1
				break
	return new_id
