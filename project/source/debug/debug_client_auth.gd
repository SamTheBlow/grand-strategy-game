extends Node
## Prints useful messages related to client authentication.
##
## To use, add this node anywhere in a scene and assign the export node.
## Make sure the scene's multiplayer API exists and is a [SceneMultiplayer].

@export var _auth_node: AuthBase


func _ready() -> void:
	var scene_multiplayer := multiplayer as SceneMultiplayer
	if scene_multiplayer == null:
		return

	if _auth_node != null:
		_auth_node.auth_data_received.connect(_on_auth_data_received)

	scene_multiplayer.peer_authenticating.connect(_on_peer_authenticating)
	scene_multiplayer.peer_authentication_failed.connect(_on_peer_auth_failed)
	scene_multiplayer.peer_connected.connect(_on_peer_connected)


func _on_peer_authenticating(_id: int) -> void:
	if not multiplayer.is_server():
		return

	MultiplayerUtils.printn(multiplayer, "A new client is trying to join.")


func _on_peer_auth_failed(_id: int) -> void:
	MultiplayerUtils.printn(multiplayer, "Authentication failed.")


func _on_peer_connected(_id: int) -> void:
	MultiplayerUtils.printn(multiplayer, "Authentication completed.")


func _on_auth_data_received(_id: int, data: PackedByteArray) -> void:
	var stream_peer_buffer := StreamPeerBuffer.new()
	stream_peer_buffer.data_array = data

	var contents: Array = []
	while stream_peer_buffer.get_position() < stream_peer_buffer.get_size():
		contents.append(stream_peer_buffer.get_var())

	MultiplayerUtils.printn(multiplayer, "Received message: " + str(contents))
