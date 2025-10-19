class_name AutoArrowProvinceReaction
## Reacts to when a province is added or removed to/from given [Game].
## Whenever a province is added or removed,
## cleans up any [AuroArrow] that interacts with that province.

var _game: Game


func _init(game: Game) -> void:
	_game = game
	game.world.provinces.added.connect(_clean_up)
	game.world.provinces.removed.connect(_clean_up)


func _clean_up(province: Province) -> void:
	for country in _game.countries.list():
		country.auto_arrows.remove_all_with_province(province.id)
