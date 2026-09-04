class_name NetworkingInterface
extends Control
## Allows the user to host a new server or join an existing one.

signal interface_changed()
signal message_sent(text: String, color: Color)

## Red
const COLOR_ERROR := Color(1.0, 0.5, 0.5)
## Yellow
const COLOR_WARNING := Color(1.0, 0.9, 0.6)
## Green
const COLOR_SUCCESS := Color(0.5, 1.0, 0.5)

## If true, the user can join an existing server by entering an IP address.
@export var can_join: bool = true:
	set(value):
		can_join = value
		if is_node_ready():
			_refresh_join_visibility()

var _session: NetworkSession

@onready var _interface_disconnected := %InterfaceDisconnected as Control
@onready var _layout_with_join := %LayoutWithJoin as Control
@onready var _ip_address_node := %IPAddress as LineEdit
@onready var _layout_without_join := %LayoutWithoutJoin as Control
@onready var _interface_connecting := %InterfaceConnecting as Control
@onready var _interface_connected := %InterfaceConnected as Control


func _ready() -> void:
	_refresh_join_visibility()
	_switch_interface(NetworkSession.State.DISCONNECTED)

	_session = NetworkSession.new()
	_session.state_changed.connect(_switch_interface)
	_session.connected.connect(_on_connected)
	_session.disconnected.connect(_on_disconnected)
	_session.connection_failed.connect(_on_connection_failed)
	add_child(_session)


func _refresh_join_visibility() -> void:
	_layout_with_join.visible = can_join
	_layout_without_join.visible = not can_join
	_interface_disconnected.custom_minimum_size = (
			_layout_with_join.custom_minimum_size if can_join else
			_layout_without_join.custom_minimum_size
	)


func _switch_interface(state: NetworkSession.State) -> void:
	_interface_connected.visible = state == NetworkSession.State.CONNECTED
	_interface_connecting.visible = state == NetworkSession.State.CONNECTING
	_interface_disconnected.visible = state == NetworkSession.State.DISCONNECTED
	match state:
		NetworkSession.State.CONNECTED:
			custom_minimum_size = _interface_connected.custom_minimum_size
		NetworkSession.State.CONNECTING:
			custom_minimum_size = _interface_connecting.custom_minimum_size
		NetworkSession.State.DISCONNECTED:
			custom_minimum_size = _interface_disconnected.custom_minimum_size
	interface_changed.emit()


#region Button presses
func _on_host_pressed() -> void:
	_session.host()


func _on_join_pressed() -> void:
	if not can_join:
		return
	_session.join(_ip_address_node.text)


func _on_disconnect_button_pressed() -> void:
	_session.disconnect_from_server()


func _on_cancel_button_pressed() -> void:
	_session.cancel_join()
#endregion


#region Networking signals
func _on_connected() -> void:
	if MultiplayerUtils.is_server(multiplayer):
		message_sent.emit(
				"You are now hosting a server! "
				+ "Other players can join using your IP address.",
				COLOR_SUCCESS
		)
	else:
		message_sent.emit("Joined server", COLOR_SUCCESS)


func _on_disconnected() -> void:
	if _interface_connecting.visible:
		message_sent.emit("Operation cancelled.", COLOR_WARNING)
	else:
		message_sent.emit("Disconnected from server.", COLOR_WARNING)


func _on_connection_failed(error: Error, is_joining: bool) -> void:
	var feedback_text: String = ""
	match error:
		ERR_ALREADY_IN_USE:
			feedback_text = "Already connected to a server."
		ERR_CANT_CREATE:
			if is_joining:
				feedback_text = "Failed to join server."
			else:
				feedback_text = "Failed to create server."
		ERR_CANT_RESOLVE:
			feedback_text = "Can't resolve (wrong IP address?)"
		ERR_TIMEOUT:
			feedback_text = "Connection timed out."
		_:
			feedback_text = "An unexpected error occured."

	message_sent.emit(feedback_text, COLOR_ERROR)
#endregion
