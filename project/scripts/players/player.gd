class_name Player
extends Node
## Class responsible for an individual player.
## This can be a human player or an AI.


signal username_changed(new_username: String)
signal human_status_changed(player: Player)
## Emits on clients when the player is done synchronizing with the server.
signal synchronization_finished(player: Player)

var id: int:
	set(value):
		if _is_not_allowed_to_make_changes():
			return
		
		id = value
		name = str(id)

var playing_country: Country

var is_human: bool = false:
	set(value):
		if _is_not_allowed_to_make_changes():
			if not is_remote():
				_request_set_is_human(value)
			return
		
		if is_human != value:
			is_human = value
			human_status_changed.emit(self)

## In a multiplayer context, tells you which client this player represents.
## If you are not connected to online multiplayer, leave this value to 1.
var multiplayer_id: int = 1

## The username that will be used if there is no custom username.
## The user may not change it manually,
## and it will not be saved in save files.
var default_username: String = "Player":
	set(value):
		if _is_not_allowed_to_make_changes():
			return
		
		var previous_username: String = username()
		default_username = value
		_check_for_username_change(previous_username)

## This username will take precedence over the default username.
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
		if multiplayer and multiplayer.is_server():
			_receive_set_custom_username.rpc(value)

var _ai_type: int:
	set(value):
		if _is_not_allowed_to_make_changes():
			return
		
		_ai_type = value

# If true, the client is allowed to make local changes.
# This is only set to true briefly when receiving data from the server.
var _is_synchronizing: bool = false

var _actions: Array[Action] = []


## Setting the AI type to a negative value gives the player a random AI type.
## The player starts with a random AI type by default.
func _init(ai_type: int = -1) -> void:
	_ai_type = ai_type
	if _ai_type < 0:
		# TODO don't hard code the number of AI types
		_ai_type = randi() % 2


func _ready() -> void:
	_request_all_data()


## Returns true if (and only if) you are connected and
## this player's multiplayer id does not match your multiplayer id.
func is_remote() -> bool:
	return (
			multiplayer
			and multiplayer.has_multiplayer_peer()
			and multiplayer.multiplayer_peer.get_connection_status()
			== MultiplayerPeer.CONNECTION_CONNECTED
			and multiplayer.get_unique_id() != multiplayer_id
	)


## Returns the player's custom username if it has one,
## otherwise returns the player's default username
func username() -> String:
	if custom_username != "":
		return custom_username
	
	return default_username


## Only works for human players.
## The AI will overwrite any action added with this command.
func add_action(action: Action) -> void:
	_actions.append(action)


func play_actions(game: Game) -> void:
	if is_human:
		_actions = []
		return
	else:
		_actions = _ai().actions(game, self)
	
	for action in _actions:
		action.apply_to(game, self)
	
	_actions.clear()


## Returns all of the player's properties as raw data.
func raw_data() -> Dictionary:
	var data := {
		"id": id,
		"is_human": is_human,
		"multiplayer_id": multiplayer_id,
		"default_username": default_username,
		"custom_username": custom_username,
		"ai_type": _ai_type,
	}
	if playing_country:
		data["playing_country_id"] = playing_country.id
	return data


## Loads all of this player's properties based on given raw data.
func load_data(data: Dictionary) -> void:
	if data.has("id"):
		id = data["id"]
	if data.has("playing_country_id"):
		# Uhh I'll figure it out later
		pass
	if data.has("is_human"):
		is_human = data["is_human"]
	if data.has("multiplayer_id"):
		multiplayer_id = data["multiplayer_id"]
	if data.has("default_username"):
		default_username = data["default_username"]
	if data.has("custom_username"):
		custom_username = data["custom_username"]
	if data.has("ai_type"):
		_ai_type = data["ai_type"]


## Returns true if, when connected online,
## the player is a client trying to make a change locally.
## When connected, only the server is allowed to make changes.
## By the way, if someone were to somehow succeed in changing the
## properties locally, the server would not know about it, so the player
## would just be desynced. This way, it's not possible to cheat.
func _is_not_allowed_to_make_changes() -> bool:
	return (
			multiplayer
			and multiplayer.has_multiplayer_peer()
			and multiplayer.multiplayer_peer.get_connection_status()
			== MultiplayerPeer.CONNECTION_CONNECTED
			and (not multiplayer.is_server())
			and (not _is_synchronizing)
	)


#region Synchronize everything
## Clients call this to ask the server for a full synchronization.
func _request_all_data() -> void:
	if (not multiplayer) or multiplayer.is_server():
		return
	
	_send_all_data.rpc_id(1)


## The server sends all of this player's properties to the clients.
@rpc("any_peer", "call_remote", "reliable")
func _send_all_data() -> void:
	if not multiplayer.is_server():
		print_debug("Received server request, but you're not the server.")
		return
	
	_receive_all_data.rpc(raw_data())


## The clients receive the data provided by the server to update this node
@rpc("authority", "call_remote", "reliable")
func _receive_all_data(data: Dictionary) -> void:
	if multiplayer.is_server():
		print_debug("The server received player data. Ignoring.")
		return
	
	_is_synchronizing = true
	load_data(data)
	_is_synchronizing = false
	synchronization_finished.emit(self)
#endregion


#region Synchronize is_human
func _request_set_is_human(value: bool) -> void:
	_consider_set_is_human.rpc_id(1, value)


@rpc("any_peer", "call_remote", "reliable")
func _consider_set_is_human(value: bool) -> void:
	if not multiplayer.is_server():
		print_debug("Received server request, but you're not the server.")
		return
	
	# Only accept if this node represents the person who made the request.
	# Unless you were given privileges (which is currently never the case),
	# you should never be able to turn other people into an AI.
	if multiplayer.get_remote_sender_id() != multiplayer_id:
		#print("D-D-D-D-D-DENIED!!")
		return
	
	# Request accepted
	_receive_set_is_human.rpc(value)


@rpc("authority", "call_local", "reliable")
func _receive_set_is_human(value: bool) -> void:
	_is_synchronizing = true
	is_human = value
	_is_synchronizing = false
#endregion


#region Synchronize custom_username
func _request_set_custom_username(value: String) -> void:
	_consider_set_custom_username.rpc_id(1, value)


@rpc("any_peer", "call_remote", "reliable")
func _consider_set_custom_username(value: String) -> void:
	if not multiplayer.is_server():
		print_debug("Received server request, but you're not the server.")
		return
	
	# Only accept if this node represents the person who made the request.
	# Unless you were given privileges (which is currently never the case),
	# you should never be able to change another player's username.
	if multiplayer.get_remote_sender_id() != multiplayer_id:
		#print_debug("Denied a username change request.")
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


func _ai() -> PlayerAI:
	match _ai_type:
		0:
			return TestAI1.new()
		1:
			return TestAI2.new()
		_:
			print_debug("Player does not have a valid AI type.")
			return null
