class_name ClientAuth
extends AuthBase
## Before a new client can join the game, retrieves information about them
## and ensures they have received the entire game state.
## Once they have joined the game, adds their players to the game.
# TODO This class has bunch lot of copy/paste in it :/

@export var players: Players

## Dictionary[int, ClientData]
## Each key is a multiplayer id; each value is the client's data.
var _client_data_list: Dictionary = {}


func _ready() -> void:
	super()
	multiplayer.peer_connected.connect(_on_peer_connected)


## The server sends its info to the client.
## We only need to send information about the node hierarchy.
## Once the client is done authenticating, nodes will synchronize themselves.
func _server_send_auth_data(id: int) -> void:
	var project_version: String = (
			ProjectSettings.get_setting("application/config/version", "")
	)

	var player_node_names: Array = []
	for player in players.list():
		player_node_names.append(player.name)

	var stream_peer_buffer := StreamPeerBuffer.new()
	stream_peer_buffer.put_var(project_version)
	stream_peer_buffer.put_var(player_node_names)

	_send_auth(id, stream_peer_buffer.data_array)


## The client sends its info to the server.
func _client_send_auth_data(id: int) -> void:
	var project_version: String = (
			ProjectSettings.get_setting("application/config/version", "")
	)

	var raw_player_data: Array = []
	for player in players.list():
		raw_player_data.append(player.raw_data())

	var stream_peer_buffer := StreamPeerBuffer.new()
	stream_peer_buffer.put_var(project_version)
	stream_peer_buffer.put_var(raw_player_data)

	_send_auth(id, stream_peer_buffer.data_array)


func _on_peer_authenticating(id: int) -> void:
	if multiplayer.is_server():
		_server_send_auth_data(id)
	else:
		_client_send_auth_data(id)


func _on_client_auth_data_received(id: int, data: PackedByteArray) -> void:
	if data.is_empty():
		_fail_auth(id)
		return

	# Get the first variable it contains (the project version).
	var stream_peer_buffer := StreamPeerBuffer.new()
	stream_peer_buffer.data_array = data
	var first_variable: Variant = stream_peer_buffer.get_var()

	if first_variable is not String:
		_fail_auth(id)
		return
	var project_version_string := first_variable as String
	var server_project_version := ProjectVersion.new(project_version_string)
	if not server_project_version.is_valid():
		_fail_auth(id)
		return

	# Currently, we accept to join the server no matter their version.

	# Fail auth if there isn't a 2nd variable in the data
	if stream_peer_buffer.get_position() >= stream_peer_buffer.get_size():
		_fail_auth(id)
		return

	# Get the 2nd variable from the data (the names of the player nodes)
	var third_variable: Variant = stream_peer_buffer.get_var()
	if third_variable is not Array:
		_fail_auth(id)
		return
	var player_node_names := third_variable as Array
	var player_node_names_typed: Array[StringName] = []
	for player_node_name: Variant in player_node_names:
		if player_node_name is not StringName:
			_fail_auth(id)
			return
		player_node_names_typed.append(player_node_name)

	# All received data is valid. Now let's apply the required changes.

	# Match the server's node hierarchy in the player list
	players.prepare_client_nodes(player_node_names_typed)

	# We don't need anything else. Complete the auth on the client's side.
	_complete_auth(id)


func _on_server_auth_data_received(id: int, data: PackedByteArray) -> void:
	if data.is_empty():
		_fail_auth(id)
		return

	# Get the first variable it contains (the project version).
	var stream_peer_buffer := StreamPeerBuffer.new()
	stream_peer_buffer.data_array = data
	var first_variable: Variant = stream_peer_buffer.get_var()

	if first_variable is not String:
		_fail_auth(id)
		return
	var project_version_string := first_variable as String
	var client_project_version := ProjectVersion.new(project_version_string)
	if not client_project_version.is_valid():
		_fail_auth(id)
		return

	# Validate their project version.
	# Deny entry when we know their version is not compatible.
	# Currently, the major & minor numbers must be equal or higher,
	# but this may change in the future if backwards compatibility is added.
	# Ignore the version suffix. We cannot know if a modded version of the game
	# is compatible or not, so we have to assume it is. Modders are responsible
	# for correctly validating online play compatibility on their version.
	var server_project_version := ProjectVersion.new()
	if (
			client_project_version.major() < server_project_version.major()
			or (
					client_project_version.major()
					== server_project_version.major()
					and client_project_version.minor()
					< server_project_version.minor()
			)
	):
		_fail_auth(id)
		return

	# Fail auth if there isn't a 2nd variable in the data
	if stream_peer_buffer.get_position() >= stream_peer_buffer.get_size():
		_fail_auth(id)
		return

	# Get the 2nd variable from the data (the player data)
	var second_variable: Variant = stream_peer_buffer.get_var()
	if second_variable is not Array:
		_fail_auth(id)
		return
	var players_data := second_variable as Array

	# Create client data object and store it
	var client_data := ClientData.new()

	for player_data: Variant in players_data:
		if player_data is not Dictionary:
			_fail_auth(id)
			return
		var player_dict := player_data as Dictionary
		client_data.players_data.append(player_dict)

	_client_data_list[id] = client_data

	# We don't need anything else. Complete the auth on the server's side.
	_complete_auth(id)


func _on_peer_connected(id: int) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	# Get the client's auth data and clean up the auth data storage
	var new_peer_data := ClientData.new()
	if _client_data_list.has(id):
		new_peer_data = _client_data_list[id]
		_client_data_list.erase(id)

	# Make sure the client is always given at least one player
	if new_peer_data.players_data.size() == 0:
		new_peer_data.players_data.append({})

	# Create and add new players
	players.server_add_client_players(id, new_peer_data.players_data)


func _on_peer_authentication_failed(id: int) -> void:
	# Clean up the auth data storage
	_client_data_list.erase(id)


## Stores and provides information about authenticating clients.
class ClientData:
	var players_data: Array[Dictionary] = []
