class_name BuildingPlacement
extends GameComponent
## During game setup, adds a fortress in every owned province without one.

const KEY: String = "building_placement"
const TITLE: String = "Building Placement"
const DESCRIPTION: String = "During game setup, adds a fortress in every owned province without one."
const SETTINGS: Array = []


func _init() -> void:
	priority_index = 7


func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	for province in game.world.provinces.list:
		if province.owner_country == null:
			continue
		if not province.buildings.list().is_empty():
			continue
		province.buildings.add(
				Building.new(game.world.fortress_data(), province.id)
		)
