class_name AutoArrowSync
extends Node
## Listens to autoarrows being added or removed.
## If you're online as the server, sends the changes to all clients.


var game: Game:
	set(value):
		game = value
		
		for country in game.countries.list():
			_on_country_added(country)
		game.countries.country_added.connect(_on_country_added)

var _connections: Array[CountryAutoArrowConnections] = []


func _enter_tree() -> void:
	# The node needs to have the same name across all clients,
	# otherwise synchronization will fail.
	name = "AutoArrowSync"


func _on_country_added(country: Country) -> void:
	_connections.append(CountryAutoArrowConnections.new(country, self))


func _on_auto_arrow_added(country: Country, auto_arrow: AutoArrow) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	
	_receive_auto_arrow_added.rpc(
			country.id, AutoArrowToDict.new().result(auto_arrow)
	)


## The client receives the info from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_auto_arrow_added(country_id: int, arrow_data: Dictionary) -> void:
	var country: Country = game.countries.country_from_id(country_id)
	var auto_arrow: AutoArrow = AutoArrowFromDict.new().result(game, arrow_data)
	country.auto_arrows.add(auto_arrow)


func _on_auto_arrow_removed(country: Country, auto_arrow: AutoArrow) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return
	
	_receive_auto_arrow_removed.rpc(
			country.id, AutoArrowToDict.new().result(auto_arrow)
	)


## The client receives the info from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_auto_arrow_removed(country_id: int, arrow_data: Dictionary) -> void:
	var country: Country = game.countries.country_from_id(country_id)
	var auto_arrow: AutoArrow = AutoArrowFromDict.new().result(game, arrow_data)
	country.auto_arrows.remove(auto_arrow)


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
