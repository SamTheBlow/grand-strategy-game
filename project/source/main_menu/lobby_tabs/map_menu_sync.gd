class_name MapMenuSync
extends Node
## Synchronizes the contents of a map selection menu between network clients.
## When online, syncs...
## - The list of built-in maps (including all of their metadata)
## - The list of custom maps (idem)
## - The currently selected map
## When leaving a server, resets the entire state to what it was before joining.


## This is the state that's being used by the UI.
## Changing something in this object will affect the visuals.
var active_state: MapMenuState:
	set(value):
		if active_state == value:
			return
		
		active_state = value
		active_state.selected_map_changed.connect(_on_selected_map_changed)
		active_state.custom_map_added.connect(_on_custom_map_added)

## This is the user's personal state.
## It stops being the active state when joining a server.
## It becomes the active state again when leaving a server.
var _saved_state: MapMenuState


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


## Updates the entire state on clients.
@rpc("authority", "call_remote", "reliable")
func _receive_state(data: Dictionary) -> void:
	active_state.set_raw_state(data)


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
		_receive_new_custom_map.rpc(map_metadata.to_dict())


## On the server, sends the current state to the new client.
func _on_peer_connected(peer_id: int) -> void:
	if MultiplayerUtils.is_server(multiplayer):
		_receive_state.rpc_id(peer_id, active_state.get_raw_state())


## Saves the current state on clients that just joined a server.
func _on_connected_to_server() -> void:
	_saved_state = MapMenuState.new()
	_saved_state.set_raw_state(active_state.get_raw_state())


## Resets the menu's state on disconnected clients.
func _on_server_disconnected() -> void:
	active_state.set_raw_state(_saved_state.get_raw_state())
