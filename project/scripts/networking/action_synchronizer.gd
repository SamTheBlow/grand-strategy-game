class_name ActionSynchronizer
extends Node
## Applies and synchronizes [Action]s across clients.
# TODO: check if a received action is valid and allowed


@export var _game: Game


func apply_action(action: Action) -> void:
	if not MultiplayerUtils.is_online(multiplayer):
		_apply_action(action)
	elif multiplayer.is_server():
		_apply_action(action)
		_receive_action.rpc(action.raw_data())
	else:
		_consider_action.rpc_id(1, action.raw_data())


@rpc("any_peer", "call_remote", "reliable")
func _consider_action(action_data: Dictionary) -> void:
	if not multiplayer.is_server():
		push_warning("Received request for server, but you're not the server")
		return
	
	_apply_action(Action.from_raw_data(action_data))
	_receive_action.rpc(action_data)


@rpc("authority", "call_remote", "reliable")
func _receive_action(action_data: Dictionary) -> void:
	_apply_action(Action.from_raw_data(action_data))


func _apply_action(action: Action) -> void:
	action.apply_to(_game, _game.turn.playing_player())
