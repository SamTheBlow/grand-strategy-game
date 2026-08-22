class_name AutoArrowProvinceCleanup
## When a province is added or removed from given game,
## removes any [AuroArrow] that uses that province's id.


static func connect_game(game: Game) -> void:
	game.world.provinces.added.connect(_clean_up.bind(game))
	game.world.provinces.removed.connect(_clean_up.bind(game))


static func _clean_up(province: Province, game: Game) -> void:
	for country in game.countries.list:
		for auto_arrow in country.auto_arrows.list():
			if (
					auto_arrow.source_province_id() == province.id
					or auto_arrow.destination_province_id() == province.id
			):
				country.auto_arrows.remove(auto_arrow)
