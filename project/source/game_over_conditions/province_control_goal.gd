class_name ProvinceControlGoal
extends GameComponent
## Ends the game when any [Country] controls enough [Province]s.

const KEY: String = "province_control_goal"

const _COUNT_KEY: String = "province_count"
const _PERCENTAGE_KEY: String = "province_percentage"

## Disabled if the value is 0.
var province_count: int = 0

## Disabled if the value is 0.
var province_percentage: float = 0.0


func _init() -> void:
	priority_index = 1


func register(game: Game) -> void:
	game.turn.started.connect(_check.bind(game))
	game.turn.turn_changed.connect(_check.bind(game).unbind(1))


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if province_count != 0:
		output[_COUNT_KEY] = province_count
	if province_percentage != 0.0:
		output[_PERCENTAGE_KEY] = province_percentage
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _COUNT_KEY):
		province_count = (
				maxi(0, ParseUtils.dictionary_int(raw_dict, _COUNT_KEY))
		)
	else:
		province_count = 0

	if ParseUtils.dictionary_has_number(raw_dict, _PERCENTAGE_KEY):
		province_percentage = maxf(
				0.0, ParseUtils.dictionary_float(raw_dict, _PERCENTAGE_KEY)
		)
	else:
		province_percentage = 0.0


func _check(game: Game) -> void:
	if province_count <= 0 and province_percentage <= 0.0:
		return

	var number_of_provinces: int = game.world.provinces.list.size()
	var province_count_per_country: Dictionary[Country, int] = (
			ProvinceCountPerCountry.result(game.world.provinces.list)
	)
	for country in province_count_per_country:
		# Count check
		if province_count > 0 and (
				province_count_per_country[country] >= province_count
		):
			game.end_game()
			return

		# Percentage check
		elif province_percentage > 0.0 and (
				float(province_count_per_country[country])
				/ number_of_provinces >= province_percentage
		):
			game.end_game()
			return
