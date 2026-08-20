class_name PopulationRandomization
extends GameComponent
## During game setup, randomizes the population
## of each [Province] using given settings.

const KEY: String = "population_randomization"

const _POPULATION_RANGE_MIN_KEY: String = "population_range_min"
const _POPULATION_RANGE_MAX_KEY: String = "population_range_max"

var min_value: int = 0
var max_value: int = 0


func _init() -> void:
	priority_index = 7


func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	for province in game.world.provinces.list:
		province.population().value = min_value + floori(
				(game.rng.randf() ** 2.0) * (max_value - min_value)
		)


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if min_value >= 0:
		output[_POPULATION_RANGE_MIN_KEY] = min_value
	if max_value >= 0:
		output[_POPULATION_RANGE_MAX_KEY] = max_value
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _POPULATION_RANGE_MIN_KEY):
		min_value = maxi(
				0,
				ParseUtils.dictionary_int(raw_dict, _POPULATION_RANGE_MIN_KEY)
		)
	else:
		min_value = 0

	if ParseUtils.dictionary_has_number(raw_dict, _POPULATION_RANGE_MAX_KEY):
		max_value = maxi(
				0,
				ParseUtils.dictionary_int(raw_dict, _POPULATION_RANGE_MAX_KEY)
		)
	else:
		max_value = 0

	if min_value > max_value:
		max_value = min_value
