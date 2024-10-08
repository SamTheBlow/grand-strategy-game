class_name Player
extends Node
## Class responsible for an individual human player.
## This object is independent of [Game] data:
## it can go from one game to another without problems.
## A player can either be local or remote. In the latter case,
## you have no control over the player unless you are the server.


signal username_changed(new_username: String)
## Emits on clients when the player is done synchronizing with the server.
signal sync_finished(player: Player)

# TODO Remove this when the ugly player assignment problem is fixed.
# It's the only system still using this variable (see [TurnOrderElement])
var id: int:
	set(value):
		if _is_not_allowed_to_make_changes():
			return
		
		id = value
		name = str(id)

## In a multiplayer context, tells you which client this player represents.
## This property is only used for online multiplayer.
var multiplayer_id: int = 1:
	set(value):
		multiplayer_id = value
		_update_is_remote()

## This username will be used if there is no custom username.
## The user may not change it manually,
## and it will not be saved in save files.
var default_username: String = "Player":
	set(value):
		if _is_not_allowed_to_make_changes():
			return
		
		var previous_username: String = username()
		default_username = value
		_check_for_username_change(previous_username)

## This username takes precedence over the default username.
## The user may change it to whatever they like,
## and it will be saved in save files.
var custom_username: String = "":
	set(value):
		if _is_not_allowed_to_make_changes():
			if not is_remote():
				_request_set_custom_username(value)
			return
		
		var previous_username: String = username()
		custom_username = value
		_check_for_username_change(previous_username)
		
		# Send custom username to clients
		if MultiplayerUtils.is_server(multiplayer):
			_receive_set_custom_username.rpc(value)

## If true, this player represents someone else.
## This is only relevant in online multiplayer.
var _is_remote: bool = false

## If true, the client is allowed to make local changes.
## This is only set to true briefly when receiving data from the server.
var _is_synchronizing: bool = false


func _ready() -> void:
	_update_is_remote()
	_request_all_data()


## Returns true if this player does not represent you. In other words,
## this player's multiplayer id does not match your multiplayer id.
func is_remote() -> bool:
	return _is_remote


## Returns the player's custom username if it has one,
## otherwise returns the player's default username
func username() -> String:
	if custom_username != "":
		return custom_username
	
	return default_username


## Returns all of the player's properties as raw data, for synchronizing.
func raw_data() -> Dictionary:
	var data := {
		"id": id,
		"multiplayer_id": multiplayer_id,
		"default_username": default_username,
		"custom_username": custom_username,
	}
	return data


# TODO verify data validity
## Loads all of this player's properties based on given raw data.
## Passing an empty Dictionary has no effect.
func load_data(data: Dictionary) -> void:
	if data.has("id"):
		id = data["id"]
	if data.has("multiplayer_id"):
		multiplayer_id = data["multiplayer_id"]
	if data.has("default_username"):
		default_username = data["default_username"]
	if data.has("custom_username"):
		custom_username = data["custom_username"]


## Returns true if, when connected online,
## the player is a client trying to make a change locally.
## When connected, only the server is allowed to make changes.
## By the way, if someone were to somehow succeed in changing the
## properties locally, the server would not know about it, so the player
## would just be desynced. This way, it's not possible to cheat.
func _is_not_allowed_to_make_changes() -> bool:
	return not (
			MultiplayerUtils.has_authority(multiplayer) or _is_synchronizing
	)


func _update_is_remote() -> void:
	if MultiplayerUtils.is_online(multiplayer):
		_is_remote = multiplayer_id != multiplayer.get_unique_id()
	else:
		_is_remote = multiplayer_id != 1


#region Synchronize everything
## Clients call this to ask the server for a full synchronization.
func _request_all_data() -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		return
	
	_send_all_data.rpc_id(1)


## The server sends all of this player's properties to the clients.
@rpc("any_peer", "call_remote", "reliable")
func _send_all_data() -> void:
	if not multiplayer.is_server():
		push_warning("Received server request, but you're not the server.")
		return
	
	_receive_all_data.rpc(raw_data())


## The clients receive the data provided by the server to update this node
@rpc("authority", "call_remote", "reliable")
func _receive_all_data(data: Dictionary) -> void:
	if multiplayer.is_server():
		push_warning("The server received player data. Ignoring.")
		return
	
	_is_synchronizing = true
	load_data(data)
	_is_synchronizing = false
	sync_finished.emit(self)
#endregion


#region Synchronize custom_username
func _request_set_custom_username(value: String) -> void:
	if not MultiplayerUtils.is_online(multiplayer):
		return
	
	_consider_set_custom_username.rpc_id(1, value)


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
	custom_username = value


@rpc("authority", "call_remote", "reliable")
func _receive_set_custom_username(value: String) -> void:
	_is_synchronizing = true
	custom_username = value
	_is_synchronizing = false
#endregion


func _check_for_username_change(previous_username: String) -> void:
	var new_username: String = username()
	if new_username != previous_username:
		username_changed.emit(new_username)
