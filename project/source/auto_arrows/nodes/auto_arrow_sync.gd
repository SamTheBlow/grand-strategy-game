class_name AutoArrowSync
extends Node
## Listens to [AutoArrow]s being added or removed in given [Game].
## The server sends changes to all clients, and clients update accordingly.
# TODO If arrows are added/removed before this node is ready on a client,
# the client will never receive the info.

var _game: Game
var _connections: Array[CountryAutoArrowConnections] = []


func _init(game: Game) -> void:
	_game = game


func _enter_tree() -> void:
	# The node needs to have the same name across all clients,
	# otherwise synchronization will fail.
	name = "AutoArrowSync"


func _ready() -> void:
	for country in _game.countries.list():
		_on_country_added(country)
	_game.countries.country_added.connect(_on_country_added)


## Clients receive the info from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_auto_arrow_added(
		country_id: int, arrow_data: Dictionary
) -> void:
	var country: Country = _game.countries.country_from_id(country_id)
	if country == null:
		push_warning("Received an invalid country id from the server.")
		return

	var auto_arrow: AutoArrow = (
			AutoArrowFromDict.new().result(_game, arrow_data)
	)
	if auto_arrow == null:
		push_warning("Received an invalid AutoArrow from the server.")
		return

	country.auto_arrows.add(auto_arrow)


## Clients receive the info from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_auto_arrow_removed(
		country_id: int, arrow_data: Dictionary
) -> void:
	var country: Country = _game.countries.country_from_id(country_id)
	if country == null:
		push_warning("Received an invalid country id from the server.")
		return

	var auto_arrow: AutoArrow = (
			AutoArrowFromDict.new().result(_game, arrow_data)
	)
	if auto_arrow == null:
		push_warning("Received an invalid AutoArrow from the server.")
		return

	country.auto_arrows.remove(auto_arrow)


func _on_country_added(country: Country) -> void:
	_connections.append(CountryAutoArrowConnections.new(country, self))


## The server sends the info to clients.
func _on_auto_arrow_added(country: Country, auto_arrow: AutoArrow) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	_receive_auto_arrow_added.rpc(
			country.id, AutoArrowToDict.new().result(auto_arrow)
	)


## The server sends the info to clients.
func _on_auto_arrow_removed(country: Country, auto_arrow: AutoArrow) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	_receive_auto_arrow_removed.rpc(
			country.id, AutoArrowToDict.new().result(auto_arrow)
	)


class CountryAutoArrowConnections:
	func _init(country: Country, auto_arrow_sync: AutoArrowSync) -> void:
		country.auto_arrows.arrow_added.connect(
				func(auto_arrow: AutoArrow) -> void:
					auto_arrow_sync._on_auto_arrow_added(country, auto_arrow)
		)
		country.auto_arrows.arrow_removed.connect(
				func(auto_arrow: AutoArrow) -> void:
					auto_arrow_sync._on_auto_arrow_removed(country, auto_arrow)
		)
