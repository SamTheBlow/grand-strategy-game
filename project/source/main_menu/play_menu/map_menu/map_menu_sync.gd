class_name MapMenuSync
extends Node
## Synchronizes the contents of a map selection menu between network clients.
## When online, syncs...
## - The list of built-in maps (including all of their metadata)
## - The list of custom maps (idem)
## - The currently selected map
## When leaving a server, resets the entire state to what it was before joining.
##
## See also: [RulesMenuSync]

## Emitted on clients when the client receives a new state from the server,
## in which case this signal will pass a new instance of [MapMenuState].
## Also emitted on clients when the client disconnects from a server,
## in which case this signal will pass a reference to the user's local state.
signal state_changed(new_state: MapMenuState)

## This is the state that's being used by the UI.
## Changing something in this object will affect the visuals.
var active_state: MapMenuState:
	set(value):
		if active_state == value:
			return

		_disconnect_signals()
		active_state = value
		_connect_signals()

		_send_active_state_to_clients()

## This is the user's personal state.
## It stops being the active state when joining a server.
## It becomes the active state again when leaving a server.
var local_state: MapMenuState


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	_request_active_state()


func _connect_signals() -> void:
	if active_state == null:
		return

	if (
			not active_state.selected_map_changed
			.is_connected(_on_selected_map_changed)
	):
		active_state.selected_map_changed.connect(_on_selected_map_changed)
	if (
			not active_state.custom_map_added
			.is_connected(_on_custom_map_added)
	):
		active_state.custom_map_added.connect(_on_custom_map_added)
	if (
			not active_state.metadata_changed
			.is_connected(_on_metadata_changed)
	):
		active_state.metadata_changed.connect(_on_metadata_changed)


func _disconnect_signals() -> void:
	if active_state == null:
		return

	if (
			active_state.selected_map_changed
			.is_connected(_on_selected_map_changed)
	):
		active_state.selected_map_changed.disconnect(_on_selected_map_changed)
	if (
			active_state.custom_map_added
			.is_connected(_on_custom_map_added)
	):
		active_state.custom_map_added.disconnect(_on_custom_map_added)
	if (
			active_state.metadata_changed
			.is_connected(_on_metadata_changed)
	):
		active_state.metadata_changed.disconnect(_on_metadata_changed)


## Clients ask the server for the active state.
## No effect if you're not a client.
func _request_active_state() -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		return

	_receive_request_active_state.rpc_id(1)


## On the server, sends the active state to all clients,
## or to one given client.
func _send_active_state_to_clients(multiplayer_id: int = -1) -> void:
	if (
			not is_node_ready()
			or not MultiplayerUtils.is_server(multiplayer)
			or active_state == null
	):
		return

	if multiplayer_id == -1:
		_receive_state.rpc(active_state.get_raw_state(false))
	else:
		_receive_state.rpc_id(multiplayer_id, active_state.get_raw_state(false))


## The server receives a client's request to receive the active state.
@rpc("any_peer", "call_remote", "reliable")
func _receive_request_active_state() -> void:
	_send_active_state_to_clients(multiplayer.get_remote_sender_id())


## Updates the entire state on clients.
@rpc("authority", "call_remote", "reliable")
func _receive_state(data: Dictionary) -> void:
	var new_state := MapMenuState.new()
	new_state.set_raw_state(data)
	state_changed.emit(new_state)


## Updates the selected map on clients.
@rpc("authority", "call_remote", "reliable")
func _receive_selected_map_id(map_id: int) -> void:
	if active_state.map_with_id(map_id) == null:
		push_error("Received invalid map id: ", map_id)
		return

	active_state.set_selected_map_id(map_id)


## Adds a new custom map to the list on clients.
@rpc("authority", "call_remote", "reliable")
func _receive_new_custom_map(raw_map_metadata: Dictionary) -> void:
	active_state.add_custom_map(MapMetadata.from_dict(raw_map_metadata))


## Updates a map's metadata on clients.
@rpc("authority", "call_remote", "reliable")
func _receive_metadata_change(
		map_id: int, raw_map_metadata: Dictionary
) -> void:
	var metadata_to_change: MapMetadata = active_state.map_with_id(map_id)
	if metadata_to_change == null:
		push_error("Received an invalid map metadata id when trying to sync.")
		return

	metadata_to_change.copy_state_of(MapMetadata.from_dict(raw_map_metadata))


## On the server, sends the newly selected map to all clients.
func _on_selected_map_changed() -> void:
	if MultiplayerUtils.is_server(multiplayer):
		_receive_selected_map_id.rpc(active_state.selected_map_id())


## On the server, sends the newly added custom map to all clients.
func _on_custom_map_added(map_metadata: MapMetadata) -> void:
	if MultiplayerUtils.is_server(multiplayer):
		_receive_new_custom_map.rpc(map_metadata.to_dict(false))


## On the server, sends the changed metadata to all clients.
func _on_metadata_changed(map_id: int, map_metadata: MapMetadata) -> void:
	if MultiplayerUtils.is_server(multiplayer):
		_receive_metadata_change.rpc(map_id, map_metadata.to_dict(false))


## Clients ask the server for the active state when they first join.
func _on_connected_to_server() -> void:
	_request_active_state()


## Resets the menu's state on disconnected clients.
func _on_server_disconnected() -> void:
	state_changed.emit(local_state)
