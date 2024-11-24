class_name PlayerAssignment
## Assigns a [Player] to a [GamePlayer] and deals with edge cases.


var _players: Players
var _game_players: GamePlayers


func _init(players: Players, game_players: GamePlayers) -> void:
	_players = players
	_game_players = game_players


## Assigns each [Player] in given list to a [GamePlayer].
## First tries to assigns it to a [GamePlayer] whose name matches.
## If it fails, then it tries to assign it to a random unassigned [GamePlayer].
## If there are no unassigned [GamePlayer]s, creates a new spectator.
## Nothing will happen for players that were already assigned beforehand.
func assign_players(players: Array[Player]) -> void:
	# Get a list of all the unassigned players.
	# We want to ignore players that were already assigned beforehand.
	var unassigned_players: Array[Player] = []
	for player in players:
		var is_player_already_assigned: bool = false
		for game_player in _game_players.list():
			if game_player.is_human and game_player.player_human == player:
				is_player_already_assigned = true
				break
		if not is_player_already_assigned:
			unassigned_players.append(player)
	if unassigned_players.size() == 0:
		return

	# Get a list of all unassigned [GamePlayer]s.
	# These will be the only valid candidates for assignation.
	var unassigned_game_players: Array[GamePlayer] = []
	for game_player in _game_players.list():
		if not game_player.is_human or game_player.player_human == null:
			unassigned_game_players.append(game_player)

	# Assign players a GamePlayer whose human_player_id matches
	for player in players:
		for game_player in (
				unassigned_game_players.duplicate() as Array[GamePlayer]
		):
			# Make sure it's still unassigned...
			if not (game_player in unassigned_game_players):
				continue

			if game_player.player_human_id != player.id:
				continue

			game_player.player_human = player
			game_player.is_human = true
			unassigned_game_players.erase(game_player)
			unassigned_players.erase(player)
			break

	# Assign players a GamePlayer whose name matches
	for player in unassigned_players.duplicate() as Array[Player]:
		for game_player in (
				unassigned_game_players.duplicate() as Array[GamePlayer]
		):
			# Make sure it's still unassigned...
			if not (game_player in unassigned_game_players):
				continue

			if game_player.username != player.username():
				continue

			game_player.player_human = player
			game_player.is_human = true
			unassigned_game_players.erase(game_player)
			unassigned_players.erase(player)
			break

	for player in unassigned_players:
		# Assign them a random unassigned GamePlayer.
		if unassigned_game_players.size() > 0:
			var random_index: int = (
					randi_range(0, unassigned_game_players.size() - 1)
			)
			var chosen_player: GamePlayer = unassigned_game_players[random_index]
			chosen_player.player_human = player
			chosen_player.is_human = true
			unassigned_game_players.erase(chosen_player)
			continue

		# There isn't any GamePlayer to assign? Create a new spectator.
		_game_players.add_player(_new_spectator(player))


func assign_all() -> void:
	assign_players(_players.list())


func assign_player(player: Player) -> void:
	assign_players([player])


## Tries to assign given [Player] to given [GamePlayer].
## If that [GamePlayer] is already associated with a [Player], or if null
## is given, goes through the normal assignment process (see _assign_players).
func assign_player_to(player: Player, game_player: GamePlayer) -> void:
	if game_player == null or game_player.player_human != null:
		assign_player(player)
		return

	game_player.player_human = player
	game_player.is_human = true


func _new_spectator(player: Player) -> GamePlayer:
	var new_spectator := GamePlayer.new()
	new_spectator.player_human = player
	new_spectator.is_human = true
	return new_spectator
