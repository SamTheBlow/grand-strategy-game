class_name MapMenuSync
extends Node
## Synchronizes the contents of a map selection menu between network clients.
## When online, syncs...
## - The list of built-in maps (including all of their metadata)
## - The list of custom maps (idem)
## - The currently selected map
## When leaving a server, resets the entire state to what it was before joining.


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
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	_send_active_state_to_clients()


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


## Sends the active state to all clients.
## Only works when you're the server.
func _send_active_state_to_clients() -> void:
	if active_state == null or not is_node_ready():
		return
	
	if MultiplayerUtils.is_server(multiplayer):
		_receive_state.rpc(active_state.get_raw_state(false))


## Updates the entire state on clients.
@rpc("authority", "call_remote", "reliable")
func _receive_state(data: Dictionary) -> void:
	var new_state := MapMenuState.new()
	new_state.set_raw_state(data)
	state_changed.emit(new_state)


## Updates the selected map on clients.
@rpc("authority", "call_remote", "reliable")
func _receive_selected_map_id(map_id: int) -> void:
	active_state.set_selected_map_id(map_id)


## Adds a new custom map to the list on clients.
@rpc("authority", "call_remote", "reliable")
func _receive_new_custom_map(raw_map_metadata: Dictionary) -> void:
	active_state.add_custom_map(MapMetadata.from_dict(raw_map_metadata))


## On the server, sends the newly selected map to all clients.
func _on_selected_map_changed() -> void:
	if MultiplayerUtils.is_server(multiplayer):
		_receive_selected_map_id.rpc(active_state.selected_map_id())


## On the server, sends the newly added custom map to all clients.
func _on_custom_map_added(map_metadata: MapMetadata) -> void:
	if MultiplayerUtils.is_server(multiplayer):
		_receive_new_custom_map.rpc(map_metadata.to_dict(false))


## On the server, sends the current state to the new client.
func _on_peer_connected(peer_id: int) -> void:
	if MultiplayerUtils.is_server(multiplayer):
		_receive_state.rpc_id(peer_id, active_state.get_raw_state(false))


## Resets the menu's state on disconnected clients.
func _on_server_disconnected() -> void:
	state_changed.emit(local_state)
