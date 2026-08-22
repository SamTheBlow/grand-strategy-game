class_name PopulationRandomization
extends GameComponent
## During game setup, randomizes the population size of each province.

const KEY: String = "population_randomization"
const TITLE: String = "Population Randomization"
const DESCRIPTION: String = "During game setup, randomizes the population size of each province."
const SETTINGS: Array = [
	{ "property_name": _MIN_VALUE_KEY, "text": "Minimum value", "type": "int", "min": 0 },
	{ "property_name": _MAX_VALUE_KEY, "text": "Maximum value", "type": "int", "min": 0 },
]

const _MIN_VALUE_KEY: String = "min_value"
const _MAX_VALUE_KEY: String = "max_value"

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
		output[_MIN_VALUE_KEY] = min_value
	if max_value >= 0:
		output[_MAX_VALUE_KEY] = max_value
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _MIN_VALUE_KEY):
		min_value = maxi(
				0,
				ParseUtils.dictionary_int(raw_dict, _MIN_VALUE_KEY)
		)
	else:
		min_value = 0

	if ParseUtils.dictionary_has_number(raw_dict, _MAX_VALUE_KEY):
		max_value = maxi(
				0,
				ParseUtils.dictionary_int(raw_dict, _MAX_VALUE_KEY)
		)
	else:
		max_value = 0

	if min_value > max_value:
		max_value = min_value
