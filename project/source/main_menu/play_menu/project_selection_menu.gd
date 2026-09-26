class_name ProjectSelectionMenu
extends VBoxContainer
## Keeps memory of currently selected project.
## Hides itself when connected to a server.

@export var _play_menu_settings: PlayMenuSettings
@export var _network_sync_data: NetworkSyncData

var _selected_project: GameOptionNode:
	set = _set_selected_project


func _ready() -> void:
	_refresh_visibility()
	multiplayer.connected_to_server.connect(_refresh_visibility)
	multiplayer.server_disconnected.connect(_refresh_visibility)
	# When connected to a server as a client,
	# the sync data matches the host's data instead of ours.
	# When we disconnect, make the sync data match our data again.
	multiplayer.server_disconnected.connect(_refresh_sync_data)


func _set_selected_project(value: GameOptionNode) -> void:
	if _selected_project != null:
		_selected_project.deselect()
	_selected_project = value
	_selected_project.select()

	_play_menu_settings.selected_project_file_path = (
			_selected_project.meta_bundle.project_absolute_path
	)
	if MultiplayerUtils.has_authority(multiplayer):
		_refresh_sync_data()


func _refresh_visibility() -> void:
	visible = MultiplayerUtils.has_authority(multiplayer)


func _refresh_sync_data() -> void:
	_network_sync_data.selected_project = _selected_project.meta_bundle
