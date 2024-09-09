class_name ActionSync
extends Node
## Listens to actions being applied to given [Game].
## If you're the server, sends changes to all clients.


var game: Game:
	set(value):
		game = value
		game.action_applied.connect(_on_action_applied)


func _init(game_: Game = null) -> void:
	game = game_


func _enter_tree() -> void:
	# The node needs to have the same name across all clients,
	# otherwise synchronization will fail.
	name = "ActionSync"


## The client receives a new [Action] from the server and applies it immediately.
@rpc("authority", "call_remote", "reliable")
func _receive_new_action(action_data: Dictionary) -> void:
	game.apply_action(Action.from_raw_data(action_data))


func _on_action_applied(action: Action) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	
	_receive_new_action.rpc(action.raw_data())
