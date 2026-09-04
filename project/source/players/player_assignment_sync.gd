class_name PlayerAssignmentSync
extends Node
## Synchronizes [Player] to [GamePlayer] assignations.
##
## By default, players are assigned to a GamePlayer whose username matches.
## But, when many players share the same username, or when no username matches,
## players are assigned at random. When that happens,
## clients need to know which Player the server assigned to which GamePlayer.
##
## See also: [PlayerAssignment]

## Emitted on clients after they first received and applied all assignations.
signal sync_finished()

var _player_assignment: PlayerAssignment
var _subscribed_clients: Array[int] = []


func _init(player_assignment: PlayerAssignment) -> void:
	_player_assignment = player_assignment


func _enter_tree() -> void:
	# The node needs to have the same name across all clients,
	# otherwise synchronization will fail.
	name = &"PlayerAssignmentSync"


func _ready() -> void:
	# The server begins listening to changes.
	_start_listening()
	multiplayer.connected_to_server.connect(_start_listening)
	multiplayer.server_disconnected.connect(_stop_listening)
	multiplayer.peer_disconnected.connect(_remove_client)

	# Clients inform the server that they are ready.
	if not MultiplayerUtils.has_authority(multiplayer):
		_add_client.rpc_id(1)


func _start_listening() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	_player_assignment.player_assigned.connect(_send_assignation)


func _stop_listening() -> void:
	# Can't use MultiplayerUtils.is_server because we've already disconnected.
	# Instead check if the signal is connected,
	# which can only be true if we were the server.
	if _player_assignment.player_assigned.is_connected(_send_assignation):
		_player_assignment.player_assigned.disconnect(_send_assignation)


## The server subscribes the sender client to new assignations
## and immediately sends them all current assignations.
@rpc("any_peer", "call_remote", "reliable")
func _add_client() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	var sender_id: int = multiplayer.get_remote_sender_id()
	_subscribed_clients.append(sender_id)

	var player_node_names: Array = []
	var game_player_ids: Array = []
	for assigned_player in _player_assignment.list:
		if (
				assigned_player == null
				or _player_assignment.list[assigned_player] is not GamePlayer
		):
			continue
		player_node_names.append(assigned_player.name)
		game_player_ids.append(_player_assignment.list[assigned_player].id)
	_receive_all.rpc_id(sender_id, player_node_names, game_player_ids)


func _remove_client(client_id: int) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	_subscribed_clients.erase(client_id)


## The client receives all current assignations and applies them locally.
@rpc("authority", "call_remote", "reliable")
func _receive_all(player_node_names: Array, game_player_ids: Array) -> void:
	if player_node_names.size() != game_player_ids.size():
		push_error("Array size mismatch.")
		return

	_player_assignment.reset()
	for i in player_node_names.size():
		_receive_one(player_node_names[i], game_player_ids[i])

	sync_finished.emit()


## The server sends a player assignation to all subscribed clients.
func _send_assignation(player: Player) -> void:
	var game_player_id: int = _player_assignment.list[player].id
	for client_id in _subscribed_clients:
		_receive_one.rpc_id(client_id, player.name, game_player_id)


## Clients receive a player assignation and apply it locally.
@rpc("authority", "call_remote", "reliable")
func _receive_one(player_node_name: String, game_player_id: int) -> void:
	_player_assignment.raw_assign_player_to(player_node_name, game_player_id)
