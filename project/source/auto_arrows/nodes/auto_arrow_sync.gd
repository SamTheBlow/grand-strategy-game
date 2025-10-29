class_name AutoArrowSync
extends Node
## Listens to [AutoArrow]s being added or removed in given [Countries].
## The server sends changes to all clients, and clients update accordingly.
# TODO If arrows are added/removed before this node is ready on a client,
# the client will never receive the info.

var _countries: Countries
var _connections: Array[CountryAutoArrowConnections] = []


func _init(countries: Countries) -> void:
	_countries = countries


func _enter_tree() -> void:
	# The node needs to have the same name across all clients,
	# otherwise synchronization will fail.
	name = "AutoArrowSync"


func _ready() -> void:
	for country in _countries.list():
		_on_country_added(country)
	_countries.added.connect(_on_country_added)


## Clients receive the info from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_auto_arrow_added(arrow_data: Variant, country_id: int) -> void:
	var country: Country = _countries.country_from_id(country_id)
	if country == null:
		push_warning("Received an invalid country id from the server.")
		return

	country.auto_arrows.add(AutoArrow.from_raw_data(arrow_data))


## Clients receive the info from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_auto_arrow_removed(arrow_data: Variant, country_id: int) -> void:
	var country: Country = _countries.country_from_id(country_id)
	if country == null:
		push_warning("Received an invalid country id from the server.")
		return

	country.auto_arrows.remove(AutoArrow.from_raw_data(arrow_data))


func _on_country_added(country: Country) -> void:
	_connections.append(CountryAutoArrowConnections.new(country, self))


## The server sends the info to clients.
func _on_auto_arrow_added(auto_arrow: AutoArrow, country: Country) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	_receive_auto_arrow_added.rpc(country.id, auto_arrow.to_raw_data())


## The server sends the info to clients.
func _on_auto_arrow_removed(auto_arrow: AutoArrow, country: Country) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	_receive_auto_arrow_removed.rpc(country.id, auto_arrow.to_raw_data())


class CountryAutoArrowConnections:
	func _init(country: Country, auto_arrow_sync: AutoArrowSync) -> void:
		country.auto_arrows.arrow_added.connect(
				auto_arrow_sync._on_auto_arrow_added.bind(country)
		)
		country.auto_arrows.arrow_removed.connect(
				auto_arrow_sync._on_auto_arrow_removed.bind(country)
		)
