class_name NetworkSession
extends Node
## Handles hosting/joining/leaving a networking session.

signal state_changed(state: State)
signal connected()
signal disconnected()
signal connection_failed(error: Error, is_joining: bool)

enum State {
	DISCONNECTED,
	CONNECTING,
	CONNECTED,
}

enum ConnectionOutcome {
	SUCCESS = 0,
	TIMEOUT = 1,
	CANCELLED = 2,
}

## The maximum number of users allowed on the server at any time,
## [b]excluding the host[/b]. Cannot exceed 4095.
@export var max_clients: int = 4095

@export var port: int = 31402

var _state: State = State.DISCONNECTED:
	set(value):
		if _state == value:
			return
		_state = value
		state_changed.emit(_state)

var _is_connecting_cancelled: bool = false


func _ready() -> void:
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	if MultiplayerUtils.is_online(multiplayer):
		_state = State.CONNECTED


func host() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error: int = peer.create_server(port, max_clients)
	if error != OK:
		connection_failed.emit(error, false)
		return

	multiplayer.set_multiplayer_peer(peer)
	# This doesn't get emitted automatically because you're the server.
	multiplayer.connected_to_server.emit()
	connected.emit()
	_state = State.CONNECTED


func join(ip_address: String) -> void:
	if ip_address == "":
		ip_address = "localhost"

	var peer := ENetMultiplayerPeer.new()
	var error: int = peer.create_client(ip_address, port)
	if error != OK:
		connection_failed.emit(error, true)
		return

	multiplayer.set_multiplayer_peer(peer)
	_state = State.CONNECTING

	_is_connecting_cancelled = false
	var connection_outcome: ConnectionOutcome = await _connection_outcome(peer)
	match connection_outcome:
		ConnectionOutcome.SUCCESS:
			connected.emit()
			_state = State.CONNECTED
		ConnectionOutcome.TIMEOUT:
			multiplayer.multiplayer_peer.close()
			connection_failed.emit(ERR_TIMEOUT, true)
			_state = State.DISCONNECTED
		ConnectionOutcome.CANCELLED:
			multiplayer.multiplayer_peer.close()
			disconnected.emit()
			_state = State.DISCONNECTED


func disconnect_from_server() -> void:
	multiplayer.multiplayer_peer.close()


func cancel_join() -> void:
	_is_connecting_cancelled = true


## Waits until the peer connects, times out, or the connection is cancelled.
func _connection_outcome(peer: MultiplayerPeer) -> ConnectionOutcome:
	# Times out after 10 seconds
	var timeout_time_ms: int = Time.get_ticks_msec() + 10_000
	while peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		if Time.get_ticks_msec() >= timeout_time_ms:
			return ConnectionOutcome.TIMEOUT
		if _is_connecting_cancelled:
			return ConnectionOutcome.CANCELLED
		await get_tree().create_timer(0.1).timeout
	return ConnectionOutcome.SUCCESS


func _on_server_disconnected() -> void:
	disconnected.emit()
	_state = State.DISCONNECTED
