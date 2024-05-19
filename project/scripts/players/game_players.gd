class_name GamePlayers
extends Node


var _list: Array[GamePlayer] = []


func add_player(player: GamePlayer) -> void:
	_list.append(player)


func remove_player(player: GamePlayer) -> void:
	if not _list.has(player):
		return
	
	_list.erase(player)


## Assigns lobby players from given group to this list.
## If a [Player]'s username matches a [GamePlayer]'s,
## it will be assigned that [GamePlayer].
## Otherwise, it will be assigned a random [GamePlayer] (not a spectator),
## or, if all [GamePlayer]s were alrady assigned, it will be assigned
## a newly created spectator [GamePlayer].
func assign_lobby(players: Players) -> void:
	var unassigned_game_players: Array[GamePlayer] = list()
	var unassigned_players: Array[Player] = players.list()
	
	# Clean up all existing assignations
	for game_player in list():
		if game_player.is_spectating():
			unassigned_game_players.erase(game_player)
		
		game_player.is_human = false
		game_player.player_human = null
	
	# Assign players whose username match
	for player in players.list():
		for game_player in _list:
			if game_player.player_human:
				continue
			
			if game_player.username == player.username():
				game_player.is_human = true
				game_player.player_human = player
				unassigned_game_players.erase(game_player)
				unassigned_players.erase(player)
				break
	
	# Assign a random GamePlayer to the remaining players
	unassigned_game_players.shuffle()
	for player in unassigned_players:
		if unassigned_game_players.size() > 0:
			unassigned_game_players[0].is_human = true
			unassigned_game_players[0].player_human = player
			unassigned_game_players.remove_at(0)
		else:
			# Ran out of GamePlayers. Create a new spectator GamePlayer.
			var new_spectator := GamePlayer.new()
			new_spectator.id = new_unique_id()
			new_spectator.is_human = true
			new_spectator.player_human = player
			add_player(new_spectator)


## Returns a copy of this list.
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


# TODO DRY. copy/paste from players.gd
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
