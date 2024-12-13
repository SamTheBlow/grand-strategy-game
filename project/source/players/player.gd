class_name Player
extends Node
## Class responsible for an individual human player.
## This object is independent of [Game] data:
## it can go from one game to another without problems.
## A player can be either local or remote.
## You have no control over remote players unless you are the server.

## Emitted, for example, when a client disconnects from a server,
## in which case all local players change their multiplayer id to 1.
signal multiplayer_id_changed(player: Player)
signal username_changed(new_username: String)
## Emitted on clients when the player is done synchronizing with the server.
signal sync_finished(player: Player)

const DATA_MULTIPLAYER_ID: String = "multiplayer_id"
const DATA_USERNAME: String = "username"

## In a multiplayer context, tells you which client this player represents.
## When offline, this is always 1.
var multiplayer_id: int = 1:
	set(value):
		if multiplayer_id == value:
			return

		multiplayer_id = value
		multiplayer_id_changed.emit(self)

		_is_remote = _calculated_is_remote()

var _username: String = "":
	set(value):
		if _username == value:
			return

		_username = value
		username_changed.emit(_username)

		# Send new username to clients
		if MultiplayerUtils.is_server(multiplayer):
			_receive_set_custom_username.rpc(value)

var _is_remote: bool = false


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	_is_remote = _calculated_is_remote()
	_request_all_data()


## Returns true if you don't have control over this player.
## In other words, this player's multiplayer id is different from yours.
func is_remote() -> bool:
	return _is_remote


func username() -> String:
	return _username


## If you're connected to a server as a client, sends a request to the server.
## Otherwise, immediately updates the player's username.
func set_username(new_username: String) -> void:
	if new_username == _username:
		return

	if not MultiplayerUtils.has_authority(multiplayer):
		_consider_set_custom_username.rpc_id(1, new_username)
		return

	_username = new_username


func _calculated_is_remote() -> bool:
	if MultiplayerUtils.is_online(multiplayer):
		return multiplayer_id != multiplayer.get_unique_id()
	else:
		return multiplayer_id != 1


# region Convert from/to raw data
## Returns all of the player's properties as raw data, for synchronizing.
func _raw_data() -> Dictionary:
	return {
		DATA_MULTIPLAYER_ID: multiplayer_id,
		DATA_USERNAME: _username,
	}


## Loads all of this player's properties based on given raw data.
## Passing an empty Dictionary has no effect.
func _load_data(data: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(data, DATA_MULTIPLAYER_ID):
		multiplayer_id = ParseUtils.dictionary_int(data, DATA_MULTIPLAYER_ID)
	if ParseUtils.dictionary_has_string(data, DATA_USERNAME):
		_username = data[DATA_USERNAME]
#endregion


#region Synchronize everything
## Clients ask the server for a full synchronization.
## No effect when offline, or when you're the server.
func _request_all_data() -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		return

	_send_all_data.rpc_id(1)


## The server sends all of this player's properties to the client who asked.
@rpc("any_peer", "call_remote", "reliable")
func _send_all_data() -> void:
	if not multiplayer.is_server():
		push_warning("Received server request, but you're not the server.")
		return

	_receive_all_data.rpc_id(multiplayer.get_remote_sender_id(), _raw_data())


## Clients receive the player's data from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_all_data(data: Dictionary) -> void:
	if multiplayer.is_server():
		push_warning("The server received player data. Ignoring.")
		return

	_load_data(data)
	sync_finished.emit(self)
#endregion


#region Synchronize username
@rpc("any_peer", "call_remote", "reliable")
func _consider_set_custom_username(value: String) -> void:
	if not multiplayer.is_server():
		push_warning("Received server request, but you're not the server.")
		return

	# Only accept if this node represents the person who made the request.
	# Unless you were given privileges (which is currently never the case),
	# you should never be able to change another player's username.
	if multiplayer.get_remote_sender_id() != multiplayer_id:
		push_warning("Denied a username change request.")
		return

	# Request accepted
	_username = value


@rpc("authority", "call_remote", "reliable")
func _receive_set_custom_username(value: String) -> void:
	_username = value
#endregion


## Clients synchronize with the server as soon as they connect.
func _on_connected_to_server() -> void:
	_is_remote = _calculated_is_remote()
	_request_all_data()
