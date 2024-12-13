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


func _init(player_assignment: PlayerAssignment) -> void:
	_player_assignment = player_assignment
	_player_assignment.player_assigned.connect(_on_player_assigned)


func _enter_tree() -> void:
	# The node needs to have the same name across all clients,
	# otherwise synchronization will fail.
	name = "PlayerAssignmentSync"


func _ready() -> void:
	# Clients ask the server for all the info.
	if MultiplayerUtils.is_online(multiplayer) and not multiplayer.is_server():
		_send_all_assignations.rpc_id(1)


## The server sends all existing assignations to whoever requested it.
@rpc("any_peer", "call_remote", "reliable")
func _send_all_assignations() -> void:
	var player_node_names: Array = []
	var game_player_ids: Array = []
	for assigned_player: Player in _player_assignment.list.keys():
		if assigned_player == null:
			continue

		if _player_assignment.list[assigned_player] is not GamePlayer:
			continue

		player_node_names.append(assigned_player.name)
		game_player_ids.append(_player_assignment.list[assigned_player].id)

	_receive_all_assignations.rpc_id(
			multiplayer.get_remote_sender_id(),
			player_node_names,
			game_player_ids
	)


## Clients receive all existing player asignations and apply them locally.
@rpc("authority", "call_remote", "reliable")
func _receive_all_assignations(
		player_node_names: Array, game_player_ids: Array
) -> void:
	if player_node_names.size() != game_player_ids.size():
		push_error(
				"player_node_names and game_player_ids "
				+ "don't have the same size."
		)
		return

	_player_assignment.reset()

	var number_of_assignations: int = player_node_names.size()
	for i in number_of_assignations:
		_receive_player_assignation(player_node_names[i], game_player_ids[i])

	sync_finished.emit()


## Clients receive a new assignation and apply it locally.
@rpc("authority", "call_remote", "reliable")
func _receive_player_assignation(
		player_node_name: String, game_player_id: int
) -> void:
	_player_assignment.raw_assign_player_to(player_node_name, game_player_id)


## The server informs all clients of the new assignation.
func _on_player_assigned(player: Player) -> void:
	if not is_node_ready() or not MultiplayerUtils.is_server(multiplayer):
		return

	# Prevent crash just in case
	if not _player_assignment.list.has(player):
		push_error(
				"Received new player assignation, but "
				+ "the player isn't on the assignation list."
		)
		return

	_receive_player_assignation.rpc(
			player.name, _player_assignment.list[player].id
	)
