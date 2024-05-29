class_name NetworkingInterface
extends Control
## The interface for hosting and joining servers.
## Allows the user to host a new server,
## or to join an existing one by providing an IP address.
## Leaving the IP address field empty defaults to localhost.


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

@onready var _interface_disconnected := $InterfaceDisconnected as Control
@onready var _interface_connected := $InterfaceConnected as Control
@onready var _ip_address_node := %IPAddress as LineEdit


func _ready() -> void:
	_switch_interface(MultiplayerUtils.is_online(multiplayer))
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _handle_error(error: Error, is_joining: bool) -> void:
	var feedback_text := ""
	# Red
	var feedback_color := Color(1, 0.5, 0.5, 1)
	
	match error:
		ERR_ALREADY_IN_USE:
			feedback_text = "Error: already connected to a server"
		ERR_CANT_CREATE:
			if is_joining:
				feedback_text = "Error: failed to join server"
			else:
				feedback_text = "Error: failed to create server"
		ERR_CANT_RESOLVE:
			feedback_text = "Error: can't resolve (wrong IP address?)"
		OK:
			# Green
			feedback_color = Color(0.5, 1, 0.5, 1)
			
			if is_joining:
				feedback_text = "Joined server"
			else:
				feedback_text = (
						"You are now hosting a server! "
						+ "Other players can join using your IP address."
				)
		_:
			feedback_text = "An unexpected error occured"
	
	message_sent.emit(feedback_text, feedback_color)


func _switch_interface(is_online: bool) -> void:
	_interface_disconnected.visible = not is_online
	_interface_connected.visible = is_online
	if is_online:
		custom_minimum_size = _interface_connected.custom_minimum_size
	else:
		custom_minimum_size = _interface_disconnected.custom_minimum_size
	interface_changed.emit()


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
	var message_text := "Disconnected from server."
	# Yellow
	var message_color := Color(1, 0.9, 0.6, 1)
	message_sent.emit(message_text, message_color)
	
	if autohide:
		show()
	_switch_interface(false)


func _on_disconnect_button_pressed() -> void:
	multiplayer.multiplayer_peer.close()
