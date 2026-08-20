class_name BuildingPlacement
extends GameComponent
## During game setup, places a fortress building in every province
## that is owned by a [Country] and does not have any buildings yet.

const KEY: String = "building_placement"


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
