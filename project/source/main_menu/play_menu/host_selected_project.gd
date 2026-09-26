class_name HostSelectedProject
extends Control
## Shows the host's currently selected project.
## Hides itself when not connected to a server.

const _GAME_OPTION_NODE_SCENE: PackedScene = preload("uid://b65o5apaw32")

@export var _network_sync_data: NetworkSyncData
@export var _container: Control


func _ready() -> void:
	_refresh_visibility()
	multiplayer.connected_to_server.connect(_refresh_visibility)
	multiplayer.server_disconnected.connect(_refresh_visibility)

	_refresh_option_node()
	_network_sync_data.selected_project_changed.connect(_refresh_option_node)


func _refresh_visibility() -> void:
	visible = not MultiplayerUtils.has_authority(multiplayer)


func _refresh_option_node() -> void:
	NodeUtils.delete_all_children(_container)

	if (
			MultiplayerUtils.has_authority(multiplayer)
			or _network_sync_data.selected_project == null
	):
		return

	var option_node := _GAME_OPTION_NODE_SCENE.instantiate() as GameOptionNode
	option_node.is_file_path_visible = false
	option_node.meta_bundle = _network_sync_data.selected_project
	# Disable interactions with the button
	option_node.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_container.add_child(option_node)
