class_name ActionInput
extends Node
## Applies a given [Action] to given [Game].
## If you're an online client, sends the action to the server instead.


var game: Game


# TODO: check if the action is valid
func apply_action(action: Action) -> void:
	if MultiplayerUtils.has_authority(multiplayer):
		game.apply_action(action)
	else:
		_receive_action_request.rpc_id(1, action.raw_data())


## The server receives an [Action] that a client wants to perform.
@rpc("any_peer", "call_remote", "reliable")
func _receive_action_request(action_data: Dictionary) -> void:
	if not multiplayer.is_server():
		push_warning("Received server request, but you're not the server.")
		return
	
	# TODO refuse if the client is not the playing player
	
	# Request accepted
	apply_action(Action.from_raw_data(action_data))
