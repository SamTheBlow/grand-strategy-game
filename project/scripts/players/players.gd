class_name Players
extends Node
## Class responsible for some group of players.


## If connected to a server as a client, this only emits
## after the player is finished synchronizing with the server.
signal player_added(player: Player)
signal player_removed(player: Player)

var _list: Array[Player]


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_connected.connect(_on_peer_connected)


## Appends a player at the bottom of the list.
func add_player(player: Player) -> void:
	for existing_player in _list:
		if existing_player.name == player.name:
			print_debug(
					"Tried to add player with already existing name."
					+ "(Name: " + player.name + ")"
			)
			return
	
	_list.append(player)
	add_child(player)
	_send_new_player_to_clients(player)
	if (not multiplayer) or multiplayer.is_server():
		player_added.emit(player)
	else:
		player.synchronization_finished.connect(_on_player_sync_finished)


func remove_player(player: Player) -> void:
	if _list.has(player):
		_list.erase(player)
		remove_child(player)
		_send_player_removal_to_clients(player)
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


func number_of_local_humans() -> int:
	var output: int = 0
	for player in _list:
		if player.is_human and not player.is_remote():
			output += 1
	if multiplayer:
		print("Output: ", output, " ...multiplayer id: ", multiplayer.get_unique_id())
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


#region Synchronize everything
## The server sends the entire list of players to whoever requested it.
@rpc("any_peer", "call_remote", "reliable")
func _send_all_data() -> void:
	if not multiplayer.is_server():
		print_debug("Received server request, but you're not the server.")
		return
	
	var node_names: PackedStringArray = []
	for player in _list:
		node_names.append(player.name)
	_receive_all_data.rpc_id(multiplayer.get_remote_sender_id(), node_names)


## The client receives the entire list of players from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_all_data(node_names: PackedStringArray) -> void:
	# Remove all the old nodes
	for player in list():
		remove_player(player)
	
	# Add the new nodes
	for node_name in node_names:
		_add_received_player(node_name)
#endregion


#region Synchronize newly added player
## The server calls this to send the info to the clients.
## If you're not connected as a server, this function has no effect.
func _send_new_player_to_clients(player: Player) -> void:
	if not _is_server():
		return
	_receive_new_player.rpc(player.name)


## The client receives one new player from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_new_player(node_name: String) -> void:
	_add_received_player(node_name)


## Add the newly received player to the bottom of the list.
## The player automatically synchronizes itself with the server.
func _add_received_player(node_name: String) -> void:
	var player := Player.new()
	player.name = node_name
	add_player(player)
#endregion


#region Synchronize player removal
## The server calls this to send the info to all clients.
## If you're not connected as a server, this function has no effect.
func _send_player_removal_to_clients(player: Player) -> void:
	if not _is_server():
		return
	_receive_player_removal.rpc(player.name)


## The client receives the name of the player to remove.
@rpc("authority", "call_remote", "reliable")
func _receive_player_removal(node_name: String) -> void:
	for player in _list:
		if player.name == node_name:
			remove_player(player)
			return
	
	print_debug(
			"Received info about removing a player,"
			+ " but that player could not be found!"
	)
#endregion


#region Synchronize client data
## Asks the client for its data. Meant to be called when the client connects.
## Only works when called by the server.
func _get_client_data(multiplayer_id: int) -> void:
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
		print_debug(
				"Received data meant for the server,"
				+ " but you're not the server."
		)
		return
	
	var multiplayer_id: int = multiplayer.get_remote_sender_id()
	for player_data: Dictionary in data:
		_add_remote_player(multiplayer_id, player_data)
#endregion


## Returns true if (and only if) you are connected and you are the server.
func _is_server() -> bool:
	return (
			multiplayer
			and multiplayer.has_multiplayer_peer()
			and multiplayer.multiplayer_peer.get_connection_status()
			== MultiplayerPeer.CONNECTION_CONNECTED
			and multiplayer.is_server()
	)


## Creates and adds a new remote player to the list.
## Only works when called by the server.
func _add_remote_player(multiplayer_id: int, player_data: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	
	var player := Player.new()
	player.load_data(player_data)
	player.id = new_unique_id()
	player.multiplayer_id = multiplayer_id
	add_player(player)


func _on_connected_to_server() -> void:
	if multiplayer.is_server():
		return
	_send_all_data.rpc_id(1)


func _on_peer_connected(multiplayer_id: int) -> void:
	_get_client_data(multiplayer_id)


func _on_player_sync_finished(player: Player) -> void:
	player_added.emit(player)
	player.synchronization_finished.disconnect(_on_player_sync_finished)
