class_name ActionSynchronizer
extends Node
## Class responsible for applying and synchronizing [Action]s across clients.


@export var _game: Game


func apply_action(action: Action) -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		_server_apply_action(action)
	else:
		_consider_action.rpc_id(1, action.raw_data())


@rpc("any_peer", "call_remote", "reliable")
func _consider_action(action_data: Dictionary) -> void:
	if not multiplayer.is_server():
		print_debug("Received request for server, but you're not the server")
		return
	_server_apply_action(Action.from_raw_data(action_data))


func _server_apply_action(action: Action) -> void:
	action.apply_to(_game, _game.turn.playing_player())
	_receive_action.rpc(action.raw_data())


@rpc("authority", "call_remote", "reliable")
func _receive_action(data: Dictionary) -> void:
	var action := Action.from_raw_data(data)
	action.apply_to(_game, _game.turn.playing_player())
