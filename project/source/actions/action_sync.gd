class_name ActionSync
extends Node
## Listens to [Action]s being applied in given [Game].
## The server sends changes to all clients, and clients update accordingly.
# TODO If a new action occurs before this node is ready on a client,
# the client will never receive the action.


var _game: Game


func _init(game: Game) -> void:
	_game = game


func _enter_tree() -> void:
	# The node needs to have the same name across all clients,
	# otherwise synchronization will fail.
	name = "ActionSync"


func _ready() -> void:
	_game.action_applied.connect(_on_action_applied)


## Clients receive a new [Action] from the server and apply it immediately.
@rpc("authority", "call_remote", "reliable")
func _receive_new_action(action_data: Dictionary) -> void:
	var action: Action = Action.from_raw_data(action_data)
	if action == null:
		push_warning("Received an invalid Action from the server.")
		return

	_game.apply_action(action)


func _on_action_applied(action: Action) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	_receive_new_action.rpc(action.raw_data())
