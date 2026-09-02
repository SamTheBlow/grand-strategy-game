class_name GameSelectMenuSync
extends Node
## Synchronizes a [GameSelectMenuState] between network clients.
## When online, syncs...
## - The list of built-in games (including all of their metadata)
## - The list of imported games (idem)
## When leaving a server, resets the entire state to what it was before joining.

@export var _play_menu_settings: PlayMenuSettings

## The state that's stored in the settings resource, for convenience.
var _active_state: GameSelectMenuState

## This is the user's personal state.
## It stops being the active state when joining a server.
## It becomes the active state again when leaving a server.
var _local_state := GameSelectMenuState.new()


func _ready() -> void:
	_active_state = _play_menu_settings.game_select_menu_state
	_active_state.selected_game_changed.connect(_send_selection)
	_active_state.imported_game_added.connect(_send_imported_game)

	_play_menu_settings.state_changed.connect(_on_state_changed)
	_play_menu_settings.game_select_menu_state = _local_state

	multiplayer.peer_connected.connect(_send_state_to)
	multiplayer.server_disconnected.connect(_restore_local_state)


## The server sends the active state to given client.
func _send_state_to(client_id: int) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	_receive_state.rpc_id(client_id, _active_state.get_raw_state(false))


## The server sends the active state to all clients.
func _send_state_to_all() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	_receive_state.rpc(_active_state.get_raw_state(false))


## Clients receive the entire state and apply it locally.
@rpc("authority", "call_remote", "reliable")
func _receive_state(raw_dict: Dictionary) -> void:
	var new_state := GameSelectMenuState.new()
	new_state.set_raw_state(raw_dict)
	_play_menu_settings.game_select_menu_state = new_state


## The server sends the newly selected game to all clients.
func _send_selection() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	_receive_selection.rpc(_active_state.selected_game_id())


## The server sends the new imported game to all clients.
func _send_imported_game(meta_bundle: MetadataBundle) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	_receive_imported_game.rpc(meta_bundle.to_raw_data(false))


## Clients receive the newly selected game and apply it locally.
@rpc("authority", "call_remote", "reliable")
func _receive_selection(game_id: int) -> void:
	if _active_state.game_with_id(game_id) == null:
		push_error("Received invalid game id: ", game_id)
		return

	_active_state.set_selected_game_id(game_id)


## Clients receive the new imported game and add it locally.
@rpc("authority", "call_remote", "reliable")
func _receive_imported_game(raw_data: Variant) -> void:
	_active_state.add_imported_game(MetadataBundle.from_raw_data(raw_data))


## Restore the active state to what it was before joining the server.
func _restore_local_state() -> void:
	_play_menu_settings.game_select_menu_state = _local_state


func _on_state_changed(
		old_value: GameSelectMenuState, new_value: GameSelectMenuState
) -> void:
	old_value.selected_game_changed.disconnect(_send_selection)
	old_value.imported_game_added.disconnect(_send_imported_game)

	_active_state = new_value
	_send_state_to_all()

	new_value.selected_game_changed.connect(_send_selection)
	new_value.imported_game_added.connect(_send_imported_game)
