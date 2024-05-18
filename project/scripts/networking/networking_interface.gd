class_name NetworkingInterface
extends Control
## A simple interface for hosting and joining servers.


signal interface_changed()
signal message_sent(text: String, color: Color)

@export var port: int = 31400

## When hosting, this is the maximum number of users
## allowed on the server at any time, [b]excluding the host[/b].
@export var max_clients: int = 2

## If set to true, this interface will go invisible 
## if the user successfully connects to a server.
## It will be visible again if the user disconnects from the server.
@export var autohide: bool = true

@onready var _interface_disconnected := $Control as Control
@onready var _interface_connected := $Control2 as Control
@onready var _ip_address_node := %IPAddress as LineEdit
@onready var _feedback := %ServerFeedback as Label
@onready var _feedback_animation := %FeedbackAnimation as AnimationPlayer


func _ready() -> void:
	_switch_interface(_is_connected())
	_feedback.text = ""
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _handle_error(error: int, joining: bool) -> void:
	# Red text
	_feedback.modulate = Color(1, 0.5, 0.5, 1)
	
	match error:
		ERR_ALREADY_IN_USE:
			_feedback.text = "Error: already connected to a server"
		ERR_CANT_CREATE:
			if joining:
				_feedback.text = "Error: failed to join server"
			else:
				_feedback.text = "Error: failed to create server"
		ERR_CANT_RESOLVE:
			_feedback.text = "Error: can't resolve (wrong IP address?)"
		OK:
			# Green text
			_feedback.modulate = Color(0.5, 1, 0.5, 1)
			
			if joining:
				_feedback.text = "Joined server"
			else:
				_feedback.text = (
						"You are now hosting a server! "
						+ "Other players can join using your IP address."
				)
		_:
			_feedback.text = "An unexpected error occured"
	
	message_sent.emit(_feedback.text, _feedback.modulate)
	_feedback_animation.play("animate_feedback")


func _switch_interface(is_online: bool) -> void:
	_interface_disconnected.visible = not is_online
	_interface_connected.visible = is_online
	if is_online:
		custom_minimum_size = _interface_connected.custom_minimum_size
	else:
		custom_minimum_size = _interface_disconnected.custom_minimum_size
	interface_changed.emit()


# TODO DRY: copy/pasted from players.gd
## Returns true if (and only if) you are connected.
func _is_connected() -> bool:
	return (
			multiplayer
			and multiplayer.has_multiplayer_peer()
			and (not multiplayer.multiplayer_peer is OfflineMultiplayerPeer)
			and multiplayer.multiplayer_peer.get_connection_status()
			== MultiplayerPeer.CONNECTION_CONNECTED
	)


func _on_host_pressed() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error: int = peer.create_server(port, max_clients)
	
	_handle_error(error, false)
	
	if error == OK:
		multiplayer.set_multiplayer_peer(peer)
		_switch_interface(true)
		
		if autohide:
			hide()
		
		# This doesn't get emitted automatically because you're the server
		multiplayer.connected_to_server.emit()


func _on_join_pressed() -> void:
	var ip_address: String = _ip_address_node.text
	if ip_address == "":
		ip_address = "localhost"
	
	var peer := ENetMultiplayerPeer.new()
	var error: int = peer.create_client(ip_address, port)
	
	_handle_error(error, true)
	
	if error == OK:
		multiplayer.set_multiplayer_peer(peer)
		_switch_interface(true)
		
		if autohide:
			hide()


func _on_server_disconnected() -> void:
	# Yellow text
	_feedback.modulate = Color(1, 0.9, 0.6, 1)
	_feedback.text = "Disconnected from server."
	message_sent.emit(_feedback.text, _feedback.modulate)
	_feedback_animation.play("animate_feedback")
	if autohide:
		show()
	_switch_interface(false)


func _on_disconnect_button_pressed() -> void:
	multiplayer.multiplayer_peer.close()
