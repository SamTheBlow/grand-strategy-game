class_name AuthBase
extends Node
## Base class for the networking authentication process.
## Has no effect.
## To use, extend this class and implement the appropriate functions.
## Please make sure this node's "multiplayer" property
## is a [SceneMultiplayer] and doesn't change.


signal auth_data_received(peer_id: int, data: PackedByteArray)


func _ready() -> void:
	var scene_multiplayer := multiplayer as SceneMultiplayer
	if scene_multiplayer == null:
		return

	scene_multiplayer.auth_callback = _on_auth_data_received
	scene_multiplayer.peer_authenticating.connect(_on_peer_authenticating)
	scene_multiplayer.peer_authentication_failed.connect(
			_on_peer_authentication_failed
	)


## Utility method.
## Shorthand for [method SceneMultiplayer.send_auth].
## The client must give their own id, not the server's.
func _send_auth(id: int, data: PackedByteArray) -> void:
	var scene_multiplayer := multiplayer as SceneMultiplayer
	if scene_multiplayer == null:
		return

	scene_multiplayer.send_auth(id, data)


## Utility method.
## Shorthand for [method SceneMultiplayer.complete_auth].
## The client must give their own id, not the server's.
func _complete_auth(id: int) -> void:
	var scene_multiplayer := multiplayer as SceneMultiplayer
	if scene_multiplayer == null:
		return

	scene_multiplayer.complete_auth(id)


## Utility method. Disconnects the client.
func _fail_auth(id: int) -> void:
	var scene_multiplayer := multiplayer as SceneMultiplayer
	if scene_multiplayer == null:
		return

	scene_multiplayer.disconnect_peer(id)


func _on_auth_data_received(id: int, data: PackedByteArray) -> void:
	auth_data_received.emit(id, data)

	if multiplayer.is_server():
		_on_server_auth_data_received(id, data)
	else:
		_on_client_auth_data_received(id, data)


## OVERRIDE THIS
## A new client is trying to join. Called on both the server and the new client.
## By default, immediately completes authentication.
func _on_peer_authenticating(id: int) -> void:
	_complete_auth(id)


## OVERRIDE THIS
## Called when the peer disconnects before authentication was completed.
func _on_peer_authentication_failed(_id: int) -> void:
	pass


## OVERRIDE THIS
## The client receives auth data from the server.
func _on_client_auth_data_received(_id: int, _data: PackedByteArray) -> void:
	pass


## OVERRIDE THIS
## The server receives auth data from the client.
func _on_server_auth_data_received(_id: int, _data: PackedByteArray) -> void:
	pass
