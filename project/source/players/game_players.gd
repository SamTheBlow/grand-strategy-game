class_name GamePlayers
## An encapsulated list of [GamePlayer] nodes.
## Provides useful functions and signals.


signal player_added(game_player: GamePlayer, position_index: int)
signal player_removed(game_player: GamePlayer)
signal username_changed(game_player: GamePlayer)

var _list: Array[GamePlayer] = []


func add_player(player: GamePlayer) -> void:
	if _list.has(player):
		return
	
	player.username_changed.connect(_on_username_changed)
	_list.append(player)
	player_added.emit(player, _list.size() - 1)


func remove_player(player: GamePlayer) -> void:
	if not _list.has(player):
		return
	
	player.username_changed.disconnect(_on_username_changed)
	_list.erase(player)
	player_removed.emit(player)


## Returns a new copy of this list.
func list() -> Array[GamePlayer]:
	return _list.duplicate()


## Returns the number of players on the list.
func size() -> int:
	return _list.size()


## Returns the player at given index position.
## If the index is not in range, returns null.
func player_from_index(index: int) -> GamePlayer:
	if index < 0 or index >= _list.size():
		return null
	return _list[index]


## Returns the player with given id.
## If there is no player with this id, returns null.
func player_from_id(id: int) -> GamePlayer:
	for game_player in _list:
		if game_player.id == id:
			return game_player
	return null


func number_of_humans() -> int:
	var output: int = 0
	for player in _list:
		if player.is_human:
			output += 1
	return output


## The number of humans on this list, minus the spectators.
func number_of_playing_humans() -> int:
	var output: int = 0
	for player in _list:
		if player.is_human and not player.is_spectating():
			output += 1
	return output


## The number of humans on this list who are not remote players
func number_of_local_humans() -> int:
	var output: int = 0
	for player in _list:
		if (
				player.is_human
				and player.player_human
				and not player.player_human.is_remote()
		):
			output += 1
	return output


# TODO DRY. copy/paste from [Players]
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


## Returns true if the client (given by its unique id) has one or more
## players playing as the given country, otherwise returns false.
func client_controls_country(multiplayer_id: int, country: Country) -> bool:
	for player in _list:
		if (
				player.is_human
				and player.player_human != null
				and player.player_human.multiplayer_id == multiplayer_id
				and player.playing_country == country
		):
			return true
	return false


## Converts this node into raw data for the purpose of saving/loading.
func raw_data() -> Array:
	var players_data: Array = []
	for player in _list:
		players_data.append(player.raw_data())
	return players_data


# TODO move this to a different class
## Finds the [GamePlayer] associated with given [Player].
## Turns it into an AI. If it's a spectator, removes it from the list.
func _on_player_removed(player: Player) -> void:
	for game_player in _list:
		if (
				not game_player.is_human
				or game_player.player_human == null
				or game_player.player_human != player
		):
			continue
		
		game_player.is_human = false
		
		if game_player.is_spectating():
			remove_player(game_player)
		
		break


func _on_username_changed(game_player: GamePlayer) -> void:
	username_changed.emit(game_player)
