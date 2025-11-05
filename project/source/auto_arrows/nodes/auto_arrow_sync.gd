class_name AutoArrowSync
extends Node
## Listens to [AutoArrow]s being added or removed in given [Countries].
## The server sends changes to all clients, and clients update accordingly.
# TODO If arrows are added/removed before this node is ready on a client,
# the client will never receive the info.

var _countries: Countries


func _init(countries: Countries) -> void:
	_countries = countries


func _enter_tree() -> void:
	# The node needs to have the same name across all clients,
	# otherwise synchronization will fail.
	name = &"AutoArrowSync"


func _ready() -> void:
	for country in _countries.list():
		_connect_country_signals(country)
	_countries.added.connect(_connect_country_signals)


func _connect_country_signals(country: Country) -> void:
	country.auto_arrows.arrow_added.connect(
			_on_auto_arrow_added.bind(country.id))
	country.auto_arrows.arrow_removed.connect(
			_on_auto_arrow_removed.bind(country.id)
	)


## The server sends the info to clients.
func _on_auto_arrow_added(auto_arrow: AutoArrow, country_id: int) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	# Make sure the country still exists.
	if _countries.country_from_id(country_id) == null:
		return

	_receive_auto_arrow_added.rpc(auto_arrow.to_raw_data(), country_id)


## The server sends the info to clients.
func _on_auto_arrow_removed(auto_arrow: AutoArrow, country_id: int) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	# Make sure the country still exists.
	if _countries.country_from_id(country_id) == null:
		return

	_receive_auto_arrow_removed.rpc(auto_arrow.to_raw_data(), country_id)


## Clients receive the info from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_auto_arrow_added(arrow_data: Variant, country_id: int) -> void:
	var country: Country = _countries.country_from_id(country_id)

	if country == null:
		push_error("Country sent by the server doesn't exist.")
		return

	country.auto_arrows.add(AutoArrow.from_raw_data(arrow_data))


## Clients receive the info from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_auto_arrow_removed(arrow_data: Variant, country_id: int) -> void:
	var country: Country = _countries.country_from_id(country_id)

	if country == null:
		push_error("Country sent by the server doesn't exist.")
		return

	country.auto_arrows.remove(AutoArrow.from_raw_data(arrow_data))
