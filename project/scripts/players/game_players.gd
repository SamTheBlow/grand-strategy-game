class_name GamePlayers
extends Node
## An encapsulated list of [GamePlayer] nodes.
## Provides useful functions and signals.


signal player_added(player: GamePlayer, position_index: int)
signal player_removed(player: GamePlayer)
signal new_human_player_requested(player: GamePlayer)

var _list: Array[GamePlayer] = []


func add_player(player: GamePlayer) -> void:
	_list.append(player)
	player.name = str(player.id)
	add_child(player)
	player_added.emit(player, _list.size() - 1)


func remove_player(player: GamePlayer) -> void:
	if not _list.has(player):
		return
	
	_list.erase(player)
	remove_child(player)
	player_removed.emit(player)


## Assigns lobby players from given group to this list.
## It first assigns players according to their id.
## Then, if a [Player]'s username matches a [GamePlayer]'s,
## it will be assigned that [GamePlayer].
## Finally, it will be assigned a random [GamePlayer] (not a spectator),
## or, if all [GamePlayer]s were alrady assigned, it will be assigned
## a newly created spectator [GamePlayer].
func assign_lobby(players: Players) -> void:
	#print("GAME PLAYERS")
	#for game_player in list():
	#	print(
	#			game_player.username, "; ",
	#			game_player.is_human, "; ", game_player.player_human_id
	#	)
	#print("PLAYERS")
	#for player in players.list():
	#	print(player.username(), "; ", player.id)
	
	players.player_removed.connect(_on_player_removed)
	
	var unassigned_game_players: Array[GamePlayer] = list()
	var unassigned_players: Array[Player] = players.list()
	
	# Clean up all existing assignations
	for game_player in list():
		if game_player.is_spectating():
			unassigned_game_players.erase(game_player)
		
		game_player.is_human = false
		game_player.player_human = null
	
	# Assign players by their id
	for player in players.list():
		for game_player in _list:
			if game_player.player_human:
				continue
			
			if game_player.player_human_id == player.id:
				game_player.player_human = player
				game_player.is_human = true
				unassigned_game_players.erase(game_player)
				unassigned_players.erase(player)
				break
	
	# Assign players whose username match
	for player in unassigned_players.duplicate() as Array[Player]:
		for game_player in _list:
			if game_player.player_human:
				continue
			
			if game_player.username == player.username():
				game_player.player_human = player
				game_player.is_human = true
				unassigned_game_players.erase(game_player)
				unassigned_players.erase(player)
				break
	
	# Assign a random GamePlayer to the remaining players
	unassigned_game_players.shuffle()
	for player in unassigned_players:
		if unassigned_game_players.size() > 0:
			unassigned_game_players[0].player_human = player
			unassigned_game_players[0].is_human = true
			unassigned_game_players.remove_at(0)
		else:
			# Ran out of GamePlayers. Create a new spectator GamePlayer.
			var new_spectator := GamePlayer.new()
			new_spectator.id = new_unique_id()
			new_spectator.player_human = player
			new_spectator.is_human = true
			add_player(new_spectator)


## Similar to [method GamePlayers.assign_lobby],
## but only assigns one [Player] instead of a whole list.
## Set the game_player_id to a positive value
## to assign the [Player] to a specific [GamePlayer].
func assign_player(player: Player, game_player_id: int = -1) -> int:
	#print("--- assign_player() called from ", multiplayer.get_unique_id())
	#print("---List of all the game players---")
	#for game_player in list():
	#	print(
	#			game_player.username, "; ",
	#			game_player.is_human, "; ", game_player.player_human_id
	#	)
	#print("------")
	#print("We're adding this player: ", player.username(), "; ", player.id)
	if game_player_id >= 0:
		var game_player: GamePlayer = player_from_id(game_player_id)
		if game_player:
			# Assign to specific GamePlayer
			#print("Assigning to specific GamePlayer: ", game_player_id)
			game_player.player_human = player
			game_player.is_human = true
			return game_player.id
		else:
			# Create new spectator
			#print("Creating new spectator: ", game_player_id)
			var new_spectator: GamePlayer = _new_spectator(player)
			add_player(new_spectator)
			return new_spectator.id
	
	var unassigned_players: Array[GamePlayer] = []
	
	# Assign them a game player whose id matches
	for game_player in _list:
		if game_player.is_human:
			continue
		
		if game_player.player_human_id == player.id:
			game_player.player_human = player
			game_player.is_human = true
			return game_player.id
	
	# Assign them a game player whose name matches
	for game_player in _list:
		if game_player.is_human:
			continue
		
		if game_player.username == player.username():
			game_player.player_human = player
			game_player.is_human = true
			return game_player.id
		
		unassigned_players.append(game_player)
	
	# There isn't one? Assign them a random AI player.
	if unassigned_players.size() > 0:
		var random_index: int = randi_range(0, unassigned_players.size() - 1)
		unassigned_players[random_index].player_human = player
		unassigned_players[random_index].is_human = true
		return unassigned_players[random_index].id
	
	# There aren't any AI players to assign? Create a new spectator.
	var spectator: GamePlayer = _new_spectator(player)
	add_player(spectator)
	return spectator.id


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


func _new_spectator(player: Player) -> GamePlayer:
	var new_spectator := GamePlayer.new()
	new_spectator.id = new_unique_id()
	new_spectator.player_human = player
	new_spectator.is_human = true
	return new_spectator


func _on_player_removed(player: Player) -> void:
	for game_player in _list:
		if (not game_player.is_human) or (not game_player.player_human):
			continue
		
		if game_player.player_human == player:
			if game_player.is_spectating():
				remove_player(game_player)
			else:
				game_player.is_human = false
			return
