class_name ActionSync
extends Node
## The server listens to [Action]s being applied in given [Game]
## and sends them to all subscribed clients. Clients update accordingly.

var _game: Game
var _subscribed_clients: Array[int] = []


func _init(game: Game) -> void:
	_game = game


func _enter_tree() -> void:
	# The node needs to have the same name across all clients,
	# otherwise synchronization will fail.
	name = &"ActionSync"


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
	_game.action_applied.connect(_send_action)


func _stop_listening() -> void:
	# Can't use MultiplayerUtils.is_server because we've already disconnected.
	# Instead check if the signal is connected,
	# which can only be true if we were the server.
	if _game.action_applied.is_connected(_send_action):
		_game.action_applied.disconnect(_send_action)


## The server subscribes the sender client to new actions.
@rpc("any_peer", "call_remote", "reliable")
func _add_client() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	_subscribed_clients.append(multiplayer.get_remote_sender_id())


func _remove_client(client_id: int) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	_subscribed_clients.erase(client_id)


## The server sends an applied action to all subscribed clients.
func _send_action(action: Action) -> void:
	for client_id in _subscribed_clients:
		_receive_action.rpc_id(client_id, action.to_raw_dict())


## Clients receive an applied action and apply it locally.
@rpc("authority", "call_remote", "reliable")
func _receive_action(action_data: Dictionary) -> void:
	var action: Action = Action.from_raw_dict(action_data)
	if action == null:
		push_error("Received an invalid action from the server.")
		return

	_game.apply_action(action)
