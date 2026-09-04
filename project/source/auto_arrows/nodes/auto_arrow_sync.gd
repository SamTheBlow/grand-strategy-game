class_name AutoArrowSync
extends Node
## The server listens to [AutoArrow]s being added/removed in given [Countries]
## and sends them to all subscribed clients. Clients update accordingly.

var _countries: Countries
var _subscribed_clients: Array[int] = []


func _init(countries: Countries) -> void:
	_countries = countries


func _enter_tree() -> void:
	# The node needs to have the same name across all clients,
	# otherwise synchronization will fail.
	name = &"AutoArrowSync"


func _ready() -> void:
	# The server begins listening to changes.
	_start_listening()
	multiplayer.connected_to_server.connect(_start_listening)
	multiplayer.server_disconnected.connect(_stop_listening)
	multiplayer.peer_disconnected.connect(_remove_client)

	# Clients inform the server that they are ready.
	if not MultiplayerUtils.has_authority(multiplayer):
		_add_client.rpc_id(1)


func _start_listening() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	for country in _countries.list:
		_connect_country(country)
	_countries.added.connect(_connect_country)
	_countries.removed.connect(_disconnect_country)


func _stop_listening() -> void:
	# Can't use MultiplayerUtils.is_server because we've already disconnected.
	# Instead check if the signal is connected,
	# which can only be true if we were the server.
	if not _countries.added.is_connected(_connect_country):
		return
	for country in _countries.list:
		_disconnect_country(country)
	_countries.added.disconnect(_connect_country)
	_countries.removed.disconnect(_disconnect_country)


func _connect_country(country: Country) -> void:
	country.auto_arrows.arrow_added.connect(_send_add.bind(country.id))
	country.auto_arrows.arrow_removed.connect(_send_remove.bind(country.id))


func _disconnect_country(country: Country) -> void:
	country.auto_arrows.arrow_added.disconnect(_send_add)
	country.auto_arrows.arrow_removed.disconnect(_send_remove)


## The server subscribes the sender client to arrow changes.
@rpc("any_peer", "call_remote", "reliable")
func _add_client() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	_subscribed_clients.append(multiplayer.get_remote_sender_id())


func _remove_client(client_id: int) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	_subscribed_clients.erase(client_id)


## The server sends an added arrow to all subscribed clients.
func _send_add(auto_arrow: AutoArrow, country_id: int) -> void:
	for client_id in _subscribed_clients:
		_receive_add.rpc_id(client_id, auto_arrow.to_raw_data(), country_id)


## The server sends a removed arrow to all subscribed clients.
func _send_remove(auto_arrow: AutoArrow, country_id: int) -> void:
	for client_id in _subscribed_clients:
		_receive_remove.rpc_id(client_id, auto_arrow.to_raw_data(), country_id)


## Clients receive an added arrow and add it locally.
@rpc("authority", "call_remote", "reliable")
func _receive_add(arrow_data: Variant, country_id: int) -> void:
	var country: Country = _countries.map.get(country_id)
	if country == null:
		push_error("Country sent by the server doesn't exist.")
		return

	country.auto_arrows.add(AutoArrow.from_raw_data(arrow_data))


## Clients receive a removed arrow and remove it locally.
@rpc("authority", "call_remote", "reliable")
func _receive_remove(arrow_data: Variant, country_id: int) -> void:
	var country: Country = _countries.map.get(country_id)
	if country == null:
		push_error("Country sent by the server doesn't exist.")
		return

	country.auto_arrows.remove(AutoArrow.from_raw_data(arrow_data))
