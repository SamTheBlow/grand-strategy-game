class_name Players
extends Node
## An encapsulated list of [Player] objects.
## Provides useful functions and signals.
## Synchronizes the list when playing online.


signal player_added(player: Player)
signal player_removed(player: Player)
signal player_kicked(player: Player)
## Emitted by the server when a new client's players are all added.
signal player_group_added(leader: Player)
## Emitted by the server when a client's players are all removed,
## usually because that client disconnected.
signal player_group_removed(leader: Player)
## This signal only emits once all of the individual players are sync'd.
signal sync_finished(players: Players)

# TODO bad code DRY: copy/paste from [Player]
var _is_synchronizing: bool = false

## Ugly code to make sure everything is synced
var _sync_check: PlayersSyncCheck

var _list: Array[Player]


func _ready() -> void:
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


## Appends given [Player] to the bottom of the list.
func add_player(player: Player) -> void:
	if _is_not_allowed_to_make_changes():
		push_warning("Tried adding a player without permission!")
		return
	
	_list.append(player)
	add_child(player)
	#_send_new_player_to_clients(player)
	player_added.emit(player)


## If connected to a server, asks the server to create a new local player.
## Otherwise, directly creates a new local player.
func add_local_human_player() -> void:
	if _is_not_allowed_to_make_changes():
		_request_add_local_player()
		return
	
	var player: Player = Player.new()
	player.id = new_unique_id()
	player.custom_username = new_default_username()
	add_player(player)


## Returns a new copy of this list.
func list() -> Array[Player]:
	return _list.duplicate()


func size() -> int:
	return _list.size()


## The number of humans on this list who are not remote players
func number_of_local_humans() -> int:
	var output: int = 0
	for player in _list:
		if not player.is_remote():
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


## Returns the first player associated with this multiplayer peer.
## If not connected, simply returns the first player on the list.
## If there are no players in the list, returns null.
func you() -> Player:
	for player in _list:
		if not player.is_remote():
			return player
	push_warning("You don't exist (is this Players list empty?)")
	return null


#region Synchronize everything
## The server sends the entire list of players to given client.
func send_all_data(multiplayer_id: int) -> void:
	if not multiplayer.is_server():
		return
	
	var node_names: PackedStringArray = []
	for player in _list:
		node_names.append(player.name)
	_receive_all_data.rpc_id(multiplayer_id, node_names)


## The client receives the entire list of players from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_all_data(node_names: PackedStringArray) -> void:
	_sync_check = PlayersSyncCheck.new()
	_sync_check.number_of_players = node_names.size()
	
	# Remove all the old nodes
	for player in list():
		_remove_player(player)
	
	# Add the new nodes
	for node_name in node_names:
		add_received_player(node_name)
	
	await _sync_check.sync_finished
	sync_finished.emit(self)
#endregion


#region Synchronize newly added player
## The server calls this to send the info to the clients.
## If you're not connected as a server, this function has no effect.
func _send_new_player_to_clients(player: Player) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	_receive_new_player.rpc(player.name)


## The client receives one new player from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_new_player(node_name: String) -> void:
	add_received_player(node_name)


## Add the newly received player to the bottom of the list.
## The player automatically synchronizes itself with the server.
func add_received_player(node_name: String) -> Player:
	var player := Player.new()
	player.name = node_name
	if _sync_check:
		# TODO bad code: private function
		player.sync_finished.connect(_sync_check._on_player_sync_finished)
	_is_synchronizing = true
	add_player(player)
	_is_synchronizing = false
	return player
#endregion


#region Synchronize client data
## Asks the client for its data. Meant to be called when the client connects.
## Only works when called by the server.
func get_client_data(multiplayer_id: int) -> void:
	if not multiplayer.is_server():
		return
	_send_client_data.rpc_id(multiplayer_id)


@rpc("authority", "call_remote", "reliable")
func _send_client_data() -> void:
	var data: Array = []
	for player in _list:
		data.append(player.raw_data())
	_receive_client_data.rpc_id(1, data)


@rpc("any_peer", "call_remote", "reliable")
func _receive_client_data(data: Array) -> void:
	if not multiplayer.is_server():
		push_warning(
				"Received data meant for the server,"
				+ " but you're not the server."
		)
		return
	
	var multiplayer_id: int = multiplayer.get_remote_sender_id()
	for player_data: Dictionary in data:
		_add_remote_player(multiplayer_id, player_data)
	
	for player in _list:
		if player.multiplayer_id == multiplayer_id:
			player_group_added.emit(player)
			break
#endregion


#region Request a new local human player
## Clients call this to ask the server for a new local player.
func _request_add_local_player() -> void:
	if multiplayer.is_server():
		push_warning("Server tried to make a server request.")
		return
	_consider_add_local_player.rpc_id(1)


@rpc("any_peer", "call_remote", "reliable")
func _consider_add_local_player() -> void:
	if not multiplayer.is_server():
		push_warning("Received server request, but you're not the server.")
		return
	
	var data := {
		"is_human": true,
		"custom_username": new_default_username(),
	}
	_add_remote_player(multiplayer.get_remote_sender_id(), data)
#endregion


#region Synchronize player removal
## If you're the server, removes the player, sends the info to clients,
## and kicks the player's client when applicable.
## If you're a client, sends a request to the server.
func remove_player(player: Player) -> void:
	if not MultiplayerUtils.has_authority(multiplayer):
		_consider_player_removal.rpc_id(1, player.name)
		return
	
	_remove_player(player)
	
	# Send the removal to clients
	_receive_player_removal.rpc(player.name)
	
	# Kick a client when removing their last player
	if _number_of_humans_with_multiplayer_id(player.multiplayer_id) == 0:
		multiplayer.multiplayer_peer.disconnect_peer(player.multiplayer_id)
		player_kicked.emit(player)


## The server receives a player removal request from a client.
@rpc("any_peer", "call_remote", "reliable")
func _consider_player_removal(player_name: String) -> void:
	if not multiplayer.is_server():
		push_warning("Received server request, but you're not the server.")
		return
	
	var player_to_remove: Player
	for player in _list:
		if player.name == player_name:
			player_to_remove = player
			break
	if player_to_remove == null:
		# Invalid player name
		return
	
	# Only accept if the user who made the request has authority over the player.
	# Unless you were given privileges (which is currently never the case),
	# you should never be able to delete other people's players.
	if multiplayer.get_remote_sender_id() != player_to_remove.multiplayer_id:
		push_warning("Someone tried to delete someone else's player.")
		return
	
	# Request accepted
	remove_player(player_to_remove)


## The client receives the name of the player to remove.
@rpc("authority", "call_remote", "reliable")
func _receive_player_removal(node_name: String) -> void:
	for player in _list:
		if player.name == node_name:
			_remove_player(player)
			return
	
	push_warning(
			"Received info about removing a player,"
			+ " but that player could not be found!"
	)
#endregion


## Removes given player from the list.
func _remove_player(player: Player) -> void:
	if not _list.has(player):
		push_warning("Tried to remove a player, but it isn't on the list!")
		return
	
	remove_child(player)
	_list.erase(player)
	player_removed.emit(player)


func _number_of_humans_with_multiplayer_id(multiplayer_id: int) -> int:
	var output: int = 0
	for player in _list:
		if player.multiplayer_id == multiplayer_id:
			output += 1
	return output


# TODO bad code DRY: copy/paste from [Player]
func _is_not_allowed_to_make_changes() -> bool:
	return not (
			MultiplayerUtils.has_authority(multiplayer) or _is_synchronizing
	)


## Creates and adds a new remote player to the list.
## Only works when called by the server.
## Optionally, you can pass existing player data as a dictionary.
## Note that if the given player data includes an id,
## that id will be overwritten.
func _add_remote_player(
		multiplayer_id: int, player_data: Dictionary = {}
) -> void:
	if not MultiplayerUtils.has_authority(multiplayer):
		return
	
	var player := Player.new()
	player.load_data(player_data)
	player.id = new_unique_id()
	player.multiplayer_id = multiplayer_id
	add_player(player)


func _on_server_disconnected() -> void:
	for player in list():
		if player.is_remote():
			_remove_player(player)
		else:
			player.multiplayer_id = 1


func _on_peer_disconnected(multiplayer_id: int) -> void:
	if not multiplayer.is_server():
		return
	
	var group_leader: Player = null
	
	for player in list():
		if player.multiplayer_id == multiplayer_id:
			if group_leader == null:
				group_leader = player
			remove_player(player)
	
	if group_leader != null:
		player_group_removed.emit(group_leader)
