class_name NetworkDataSync
extends Node
## Synchronizes data between host and clients.
## This centralized approach prevents errors about the node not existing
## on the other end, as this node always exists on both ends.

const _NO_DATA: String = ""

@export var _network_sync_data: NetworkSyncData


func _ready() -> void:
	_network_sync_data.selected_project_changed.connect(_send_selected_project)
	multiplayer.peer_connected.connect(_send_data_to)


## The server sends all data to given client.
func _send_data_to(client_id: int) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	_receive_selected_project.rpc_id(
			client_id,
			_network_sync_data.selected_project.to_raw_data(false)
			if _network_sync_data.selected_project != null else _NO_DATA
	)


## The server sends the selected project to all clients.
func _send_selected_project() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	_receive_selected_project.rpc(
			_network_sync_data.selected_project.to_raw_data(false)
			if _network_sync_data.selected_project != null else _NO_DATA
	)


## Clients receive the selected project and apply it locally.
@rpc("authority", "call_remote", "reliable")
func _receive_selected_project(raw_data: Variant) -> void:
	_network_sync_data.selected_project = (
			null if is_same(raw_data, _NO_DATA) else
			MetadataBundle.from_raw_data(raw_data)
	)
