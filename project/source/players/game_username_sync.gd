class_name GameUsernameSync
extends Node
## The server listens to username changes in given [GamePlayers]
## and sends them to all subscribed clients. Clients update accordingly.

var _game_players: GamePlayers
var _subscribed_clients: Array[int] = []


func _init(game_players: GamePlayers) -> void:
	_game_players = game_players


func _enter_tree() -> void:
	# The node needs to have the same name across all clients,
	# otherwise synchronization will fail.
	name = &"UsernameSync"


func _ready() -> void:
	# The server begins listening to changes.
	_start_listening()
	multiplayer.connected_to_server.connect(_start_listening)
	multiplayer.server_disconnected.connect(_stop_listening)
	multiplayer.peer_disconnected.connect(_remove_client)

	# Clients inform the server that they are ready.
	if not MultiplayerUtils.has_authority(multiplayer):
		_add_client.rpc_id(1)


func _start_listening() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	_game_players.username_changed.connect(_send_username_change)


func _stop_listening() -> void:
	# Can't use MultiplayerUtils.is_server because we've already disconnected.
	# Instead check if the signal is connected,
	# which can only be true if we were the server.
	if _game_players.username_changed.is_connected(_send_username_change):
		_game_players.username_changed.disconnect(_send_username_change)


## The server subscribes the sender client to username changes
## and immediately sends them all current usernames.
@rpc("any_peer", "call_remote", "reliable")
func _add_client() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	var sender_id: int = multiplayer.get_remote_sender_id()
	_subscribed_clients.append(sender_id)

	var game_player_ids: Array = []
	var usernames: Array = []
	for game_player in _game_players.list():
		game_player_ids.append(game_player.id)
		usernames.append(game_player.username)
	_receive_all.rpc_id(sender_id, game_player_ids, usernames)


func _remove_client(client_id: int) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	_subscribed_clients.erase(client_id)


## The client receives all current usernames and applies them locally.
@rpc("authority", "call_remote", "reliable")
func _receive_all(game_player_ids: Array, usernames: Array) -> void:
	if game_player_ids.size() != usernames.size():
		push_error("Array size mismatch.")
		return

	for i in game_player_ids.size():
		var game_player: GamePlayer = (
				_game_players.player_from_id(game_player_ids[i])
		)
		if game_player == null:
			push_error("Received an invalid player id.")
			continue

		game_player.username = usernames[i]


## The server sends a username change to all subscribed clients.
func _send_username_change(game_player: GamePlayer) -> void:
	for client_id in _subscribed_clients:
		_receive_one.rpc_id(client_id, game_player.id, game_player.username)


## Clients receive a username change and apply it locally.
@rpc("authority", "call_remote", "reliable")
func _receive_one(game_player_id: int, new_username: String) -> void:
	var game_player: GamePlayer = _game_players.player_from_id(game_player_id)
	if game_player == null:
		push_warning("Received an invalid GamePlayer id from the server.")
		return

	game_player.username = new_username
