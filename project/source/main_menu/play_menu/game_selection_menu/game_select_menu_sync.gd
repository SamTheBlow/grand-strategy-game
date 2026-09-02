class_name GameSelectMenuSync
extends Node
## Synchronizes the contents of a [GameSelectionMenu] between network clients.
## When online, syncs...
## - The list of built-in games (including all of their metadata)
## - The list of imported games (idem)
## When leaving a server, resets the entire state to what it was before joining.

## Emitted on clients when the client receives a new state from the server,
## in which case this signal will pass a new instance of [GameSelectMenuState].
## Also emitted on clients when the client disconnects from a server,
## in which case this signal will pass a reference to the user's local state.
signal state_changed(new_state: GameSelectMenuState)

## This is the state that's being used by the UI.
## Changing something in this object will affect the visuals.
var active_state: GameSelectMenuState:
	set(value):
		if active_state == value:
			return

		if active_state != null:
			active_state.selected_game_changed.disconnect(_send_selection)
			active_state.imported_game_added.disconnect(_send_imported_game)

		active_state = value
		_send_state()

		active_state.selected_game_changed.connect(_send_selection)
		active_state.imported_game_added.connect(_send_imported_game)

## This is the user's personal state.
## It stops being the active state when joining a server.
## It becomes the active state again when leaving a server.
var local_state: GameSelectMenuState

## A list of clients who have subscribed to synchronization.
## Only used by the server.
var _subscribed_clients: Array[int] = []


func _ready() -> void:
	# Connected clients immediately subscribe.
	_subscribe_to_synchronization()
	# Clients subscribe when they join a server.
	multiplayer.connected_to_server.connect(_subscribe_to_synchronization)

	multiplayer.server_disconnected.connect(_on_server_disconnected)

	# The server unsubscribes clients when they disconnect.
	multiplayer.peer_disconnected.connect(_remove_client)


func _subscribe_to_synchronization() -> void:
	if not MultiplayerUtils.has_authority(multiplayer):
		_add_client.rpc_id(1)


## The server subscribes the sender client to menu state changes
## and immediately sends them the current state.
@rpc("any_peer", "call_remote", "reliable")
func _add_client() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	var sender_id: int = multiplayer.get_remote_sender_id()
	_subscribed_clients.append(sender_id)

	_receive_state.rpc_id(sender_id, active_state.get_raw_state(false))


func _remove_client(client_id: int) -> void:
	if MultiplayerUtils.is_server(multiplayer):
		_subscribed_clients.erase(client_id)


## The server sends the active state to all subscribed clients.
func _send_state() -> void:
	if not is_node_ready() or not MultiplayerUtils.is_server(multiplayer):
		return

	for client_id in _subscribed_clients:
		_receive_state.rpc_id(client_id, active_state.get_raw_state(false))


## Clients receive the entire state and apply it locally.
@rpc("authority", "call_remote", "reliable")
func _receive_state(data: Dictionary) -> void:
	var new_state := GameSelectMenuState.new()
	new_state.set_raw_state(data)
	state_changed.emit(new_state)


## The server sends the newly selected game to all subscribed clients.
func _send_selection() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	for client_id in _subscribed_clients:
		_receive_selection.rpc_id(client_id, active_state.selected_game_id())


## The server sends the new imported game to all subscribed clients.
func _send_imported_game(meta_bundle: MetadataBundle) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	for client_id in _subscribed_clients:
		_receive_imported_game.rpc_id(client_id, meta_bundle.to_raw_data(false))


## Clients receive the newly selected game and apply it locally.
@rpc("authority", "call_remote", "reliable")
func _receive_selection(game_id: int) -> void:
	if active_state.game_with_id(game_id) == null:
		push_error("Received invalid game id: ", game_id)
		return

	active_state.set_selected_game_id(game_id)


## Clients receive the new imported game and add it locally.
@rpc("authority", "call_remote", "reliable")
func _receive_imported_game(raw_data: Variant) -> void:
	active_state.add_imported_game(MetadataBundle.from_raw_data(raw_data))


## Resets the menu's state on disconnected clients.
func _on_server_disconnected() -> void:
	state_changed.emit(local_state)
