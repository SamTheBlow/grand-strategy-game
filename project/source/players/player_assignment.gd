class_name PlayerAssignment
## Holds a list of which [Player] is assigned to which [GamePlayer].
## Ensures the list always contains all players
## in given [Players] list, even those who are not assigned.
## When a client joins, the server automatically assigns its new players.

## Emitted when a player is assigned either to a GamePlayer or to null.
signal player_assigned(player: Player)

## Dictionary[Player, GamePlayer]
## Each [Player] is assigned zero or one [GamePlayer].
## All players are guaranteed to be a valid key.
## If a player does not have a [GamePlayer] assigned, its value is null.
var list: Dictionary = {}

var _game_players: GamePlayers


func _init(players: Players, game_players: GamePlayers) -> void:
	_game_players = game_players

	# Initialize the list. Make sure all players are a valid key.
	for player in players.list():
		list[player] = null

	players.player_added.connect(_on_player_added)
	players.player_removed.connect(_on_player_removed)
	players.player_group_added.connect(_on_player_group_added)


## Unassigns all players.
## Sets the value of all keys in the list to null.
func reset() -> void:
	for player: Player in list.keys():
		assign_player_to(player, null)


## Assigns given [Player] to given [GamePlayer].
## If given [Player] already had a [GamePlayer] assigned,
## overwrites the previous assignation.
## If given [GamePlayer] already had another [Player] assigned to it,
## pushes an error and nothing happens. If given [GamePlayer] is null,
## given [Player] will not be assigned to any [GamePlayer].
func assign_player_to(player: Player, game_player: GamePlayer) -> void:
	# Check if GamePlayer can be assigned
	if (
			game_player != null
			and game_player.is_human
			and game_player.player_human != null
	):
		push_error("This GamePlayer is already assigned to a Player.")
		return

	# Erase previous assignation
	if list.has(player) and list[player] != null:
		var previously_assigned := list[player] as GamePlayer
		if previously_assigned != null:
			previously_assigned.player_human = null
			previously_assigned.is_human = false

	list[player] = game_player
	if game_player != null:
		game_player.player_human = player
		game_player.is_human = true
	player_assigned.emit(player)


## Does the same thing as "assign_player_to", but takes raw data as input.
## Pushes an error if given raw data is invalid.
func raw_assign_player_to(
		player_node_name: String, game_player_id: int
) -> void:
	var player: Player = null
	for list_player: Player in list.keys():
		if list_player.name == player_node_name:
			player = list_player
			break
	if player == null:
		push_error(
				"Received player assignation, but "
				+ "could not find player with given node name."
		)
		return

	var game_player: GamePlayer = _game_players.player_from_id(game_player_id)
	if game_player == null:
		push_error(
				"Received player assignation, but "
				+ "could not find GamePlayer with given id."
		)
		return

	assign_player_to(player, game_player)


func assign_player(player: Player) -> void:
	assign_players([player])


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
		if not list.has(player):
			push_error("Tried to assign a player that isn't on the list.")
			return
		if list[player] == null:
			unassigned_players.append(player)
	if unassigned_players.size() == 0:
		return

	# Get a list of all unassigned [GamePlayer]s.
	# These will be the only valid candidates for assignation.
	var unassigned_game_players: Array[GamePlayer] = []
	for game_player in _game_players.list():
		if not game_player.is_human or game_player.player_human == null:
			unassigned_game_players.append(game_player)

	# Assign players a GamePlayer whose name matches
	for player in unassigned_players.duplicate() as Array[Player]:
		for game_player in (
				unassigned_game_players.duplicate() as Array[GamePlayer]
		):
			# Make sure it's still unassigned...
			if not unassigned_game_players.has(game_player):
				continue

			if game_player.username != player.username():
				continue

			assign_player_to(player, game_player)
			unassigned_game_players.erase(game_player)
			unassigned_players.erase(player)
			break

	for player in unassigned_players:
		# If there isn't any GamePlayer to assign, assign the player to nobody.
		if unassigned_game_players.size() == 0:
			assign_player_to(player, null)
			continue

		# Assign them a random unassigned GamePlayer.
		var random_index: int = (
				randi_range(0, unassigned_game_players.size() - 1)
		)
		var random_game_player: GamePlayer = (
				unassigned_game_players[random_index]
		)
		assign_player_to(player, random_game_player)
		unassigned_game_players.erase(random_game_player)


func _on_player_added(player: Player) -> void:
	if not list.has(player):
		list[player] = null


func _on_player_removed(player: Player) -> void:
	list.erase(player)


func _on_player_group_added(players: Array[Player]) -> void:
	assign_players(players)
