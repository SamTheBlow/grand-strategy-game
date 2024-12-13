class_name NetworkingInterface
extends Control
## The interface for hosting and joining servers.
## Allows the user to host a new server,
## or to join an existing one by providing an IP address.
## Leaving the IP address field empty defaults to localhost.

signal interface_changed()
signal message_sent(text: String, color: Color)

## When hosting, this is the maximum number of users
## allowed on the server at any time, [b]excluding the host[/b].
## Note that this cannot exceed 4095.
@export var max_clients: int = 4095

## If set to true, this interface will go invisible
## if the user successfully connects to a server.
## It will be visible again if the user disconnects from the server.
@export var autohide: bool = true

var _port: int = 31401

## Red
var _color_error := Color(1, 0.5, 0.5, 1)
## Yellow
var _color_warning := Color(1, 0.9, 0.6, 1)
## Green
var _color_success := Color(0.5, 1, 0.5, 1)

var _is_connecting_cancelled: bool = false

@onready var _interface_disconnected := $InterfaceDisconnected as Control
@onready var _interface_connecting := $InterfaceConnecting as Control
@onready var _interface_connected := $InterfaceConnected as Control
@onready var _ip_address_node := %IPAddress as LineEdit


func _ready() -> void:
	var interface: int = 2
	if MultiplayerUtils.is_online(multiplayer):
		interface = 0
	_switch_interface(interface)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _handle_error(error: Error, is_joining: bool) -> void:
	if error == OK:
		return

	var feedback_text := ""
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
		_:
			feedback_text = "An unexpected error occured"

	message_sent.emit(feedback_text, _color_error)


## 0: connected, 1: connecting, 2: disconnected
func _switch_interface(interface: int) -> void:
	_interface_connected.visible = interface == 0
	_interface_connecting.visible = interface == 1
	_interface_disconnected.visible = interface == 2
	match interface:
		0:
			custom_minimum_size = _interface_connected.custom_minimum_size
		1:
			custom_minimum_size = _interface_connecting.custom_minimum_size
		2:
			custom_minimum_size = _interface_disconnected.custom_minimum_size
	interface_changed.emit()


## When a client is connecting to a server, returns 0 if it
## succeeded, 1 if it timed out, or 2 it connection was cancelled.
func _connection_outcome(peer: MultiplayerPeer) -> int:
	# Times out after 10 seconds
	var timeout_time_ms: int = Time.get_ticks_msec() + 10_000

	while peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		if Time.get_ticks_msec() >= timeout_time_ms:
			return 1
		if _is_connecting_cancelled:
			return 2
		await get_tree().create_timer(0.1).timeout
	return 0


func _on_host_pressed() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error: int = peer.create_server(_port, max_clients)

	_handle_error(error, false)

	if error == OK:
		var feedback_text: String = (
				"You are now hosting a server! "
				+ "Other players can join using your IP address."
		)
		message_sent.emit(feedback_text, _color_success)

		multiplayer.set_multiplayer_peer(peer)
		_switch_interface(0)

		if autohide:
			hide()

		# This doesn't get emitted automatically because you're the server
		multiplayer.connected_to_server.emit()


func _on_join_pressed() -> void:
	var ip_address: String = _ip_address_node.text
	if ip_address == "":
		ip_address = "localhost"

	var peer := ENetMultiplayerPeer.new()
	var error: int = peer.create_client(ip_address, _port)

	_handle_error(error, true)

	if error != OK:
		return

	multiplayer.set_multiplayer_peer(peer)
	_switch_interface(1)
	message_sent.emit("Joining server...", _color_warning)

	_is_connecting_cancelled = false
	var connection_outcome: int = await _connection_outcome(peer)
	if connection_outcome == 1:
		_switch_interface(2)
		var message := "Failed to join server: connection timed out."
		message_sent.emit(message, _color_error)
		multiplayer.multiplayer_peer.close()
		return
	elif connection_outcome == 2:
		_switch_interface(2)
		var message := "Operation cancelled."
		message_sent.emit(message, _color_warning)
		multiplayer.multiplayer_peer.close()
		return

	_switch_interface(0)
	message_sent.emit("Joined server", _color_success)

	if autohide:
		hide()


func _on_server_disconnected() -> void:
	var message_text := "Disconnected from server."
	message_sent.emit(message_text, _color_warning)

	if autohide:
		show()
	_switch_interface(2)


func _on_disconnect_button_pressed() -> void:
	multiplayer.multiplayer_peer.close()


func _on_cancel_button_pressed() -> void:
	_is_connecting_cancelled = true
