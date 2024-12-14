class_name Players
extends Node
## An encapsulated list of [Player] objects.
## Provides useful functions and signals.
## Synchronizes the list when playing online.

signal player_added(player: Player)
signal player_removed(player: Player)
## Emitted by the server when a client's last player is removed.
signal player_kicked(player: Player)
## Emitted by the server when a new client's players are all added.
signal player_group_added(players: Array[Player])
## Emitted by the server when a client's players are all removed,
## usually because that client disconnected.
signal player_group_removed(leader: Player)

var _list: Array[Player]


func _ready() -> void:
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


## Creates a new player with given multiplayer_id, and returns it.
## Note: this does not add it to the list.
func new_player(multiplayer_id: int = 1) -> Player:
	var player := Player.new()
	player.multiplayer_id = multiplayer_id
	player.set_username(_default_username())
	return player


## Adds one new player, with default values.
func add_new_player() -> void:
	add_player(new_player())


## Adds given player to the bottom of the list.
## Gives the player node a unique name.
## If you're the server, sends the info to all clients.
func add_player(player: Player) -> void:
	if _list.has(player):
		push_warning("Tried to add player, but it was already on the list.")
		return

	_list.append(player)
	add_child(player, true)
	_send_new_player_to_clients(player)
	player_added.emit(player)


## Removes the player and kicks client if that was their last player.
## If you're a client, sends a request to the server instead.
func remove_player(player: Player) -> void:
	if not MultiplayerUtils.has_authority(multiplayer):
		_consider_player_removal.rpc_id(1, player.name)
		return

	_remove_player(player)

	# Kick a client when removing their last player
	if (
			MultiplayerUtils.is_server(multiplayer)
			and leader_of(player.multiplayer_id) == null
	):
		multiplayer.disconnect_peer(player.multiplayer_id)
		player_kicked.emit(player)


## Returns a new copy of this list.
func list() -> Array[Player]:
	return _list.duplicate()


## The number of players.
func size() -> int:
	return _list.size()


## The number of players who are not remote players.
func number_of_local_players() -> int:
	var output: int = 0
	for player in _list:
		if not player.is_remote():
			output += 1
	return output


## Returns the first player associated with given multiplayer id.
## If there are no players with that id, returns null.
func leader_of(multiplayer_id: int) -> Player:
	for player in _list:
		if player.multiplayer_id == multiplayer_id:
			return player
	return null


## Returns the first player associated with the local multiplayer peer.
## When not online, this returns the first player on the list.
## If there are no players in the list, returns null.
func you() -> Player:
	for player in _list:
		if not player.is_remote():
			return player
	push_warning("You don't exist (is this Players list empty?)")
	return null


## Removes all existing players
## and creates new player nodes for each given node name.
func prepare_client_nodes(node_names: Array[StringName]) -> void:
	for player in list():
		_remove_player(player)
	for node_name in node_names:
		_add_player_with_node_name(node_name)


## The server adds a new client's players to the list.
## Emits a signal when at least one player is added.
func server_add_client_players(
		multiplayer_id: int, players_data: Array[Dictionary]
) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		push_warning(
				"Tried to add a client's players, but you're not the server."
		)
		return

	if players_data.size() == 0:
		return

	var player_list: Array[Player] = []
	for player_data in players_data:
		var player := Player.new()
		# The order is important here.
		player.set_username(_default_username())
		player.load_data(player_data)
		player.multiplayer_id = multiplayer_id
		add_player(player)
		player_list.append(player)

	player_group_added.emit(player_list)


## If given node name is already taken,
## pushes an error and does not add a new player.
func _add_player_with_node_name(node_name: String) -> void:
	if has_node(node_name):
		push_error("Player node name is already taken.")
		return

	var player := Player.new()
	player.name = node_name

	_list.append(player)
	add_child(player)
	_send_new_player_to_clients(player)
	player_added.emit(player)


## Removes given player from the list and notifies clients if applicable.
func _remove_player(player: Player) -> void:
	if not _list.has(player):
		push_warning("Tried to remove a player, but it isn't on the list!")
		return

	remove_child(player)
	_list.erase(player)
	player_removed.emit(player)

	# Notify clients
	if MultiplayerUtils.is_server(multiplayer):
		_receive_player_removal.rpc(player.name)


## Provides the default username for a potential new player.
## For example, if there are already players named "Player 1" and "Player 2",
## then this function will return "Player 3".
func _default_username() -> String:
	const PLAYER_PREFIX: String = "Player "
	var player_number: int = 1
	var is_invalid_number: bool = true
	while is_invalid_number:
		is_invalid_number = false
		for player in _list:
			if player.username() == PLAYER_PREFIX + str(player_number):
				is_invalid_number = true
				player_number += 1
				break
	return PLAYER_PREFIX + str(player_number)


#region Synchronize newly added player
## The server sends the info to all clients.
## If you're not an online server, this has no effect.
func _send_new_player_to_clients(player: Player) -> void:
	if MultiplayerUtils.is_server(multiplayer):
		_receive_new_player.rpc(player.name)


## Clients receive a new player from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_new_player(node_name: String) -> void:
	_add_player_with_node_name(node_name)
#endregion


#region Request a new local human player
@rpc("any_peer", "call_remote", "reliable")
func _consider_add_local_player() -> void:
	if not multiplayer.is_server():
		push_warning("Received server request, but you're not the server.")
		return

	add_player(new_player(multiplayer.get_remote_sender_id()))
#endregion


#region Synchronize player removal
## The server receives a player removal request from a client.
@rpc("any_peer", "call_remote", "reliable")
func _consider_player_removal(node_name: String) -> void:
	if not multiplayer.is_server():
		push_warning("Received server request, but you're not the server.")
		return

	var player_to_remove: Player
	for player in _list:
		if player.name == node_name:
			player_to_remove = player
			break
	if player_to_remove == null:
		# Invalid player name
		return

	# Only accept if the user who made the request
	# has authority over the player.
	# Unless they were given privileges (which is currently never the case),
	# they should never be able to delete other people's players.
	if multiplayer.get_remote_sender_id() != player_to_remove.multiplayer_id:
		push_warning("Someone tried to delete someone else's player.")
		return

	# Request accepted
	_remove_player(player_to_remove)


## The client receives the name of the player to remove.
@rpc("authority", "call_remote", "reliable")
func _receive_player_removal(node_name: String) -> void:
	for player in _list:
		if player.name == node_name:
			_remove_player(player)
			return

	push_warning("Cannot find player with given node name.")
#endregion


## When disconnected (on both server and client),
## removes all remote players from the list.
func _on_server_disconnected() -> void:
	for player in list():
		if player.is_remote():
			_remove_player(player)
		else:
			player.multiplayer_id = 1


## When a client disconnects, the server removes all of that client's players.
func _on_peer_disconnected(multiplayer_id: int) -> void:
	if not multiplayer.is_server():
		return

	var group_leader: Player = null

	for player in list():
		if player.multiplayer_id == multiplayer_id:
			if group_leader == null:
				group_leader = player
			_remove_player(player)

	if group_leader != null:
		player_group_removed.emit(group_leader)
