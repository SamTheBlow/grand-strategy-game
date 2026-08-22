class_name ProvinceIncomeRandomization
extends GameComponent
## During game setup, randomizes the money income of each province.

const KEY: String = "province_income_randomization"
const TITLE: String = "Province Income Randomization"
const DESCRIPTION: String = "During game setup, randomizes the money income of each province."
const SETTINGS: Array = [
	{ "property_name": _MIN_VALUE_KEY, "text": "Minimum value", "type": "int" },
	{ "property_name": _MAX_VALUE_KEY, "text": "Maximum value", "type": "int" },
]

const _MIN_VALUE_KEY: String = "min_value"
const _MAX_VALUE_KEY: String = "max_value"

var min_value: int = 0
var max_value: int = 0


func _init() -> void:
	priority_index = 5


func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	for province in game.world.provinces.list:
		province.money_income().value = (
				game.rng.randi_range(min_value, max_value)
		)


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if min_value != 0:
		output[_MIN_VALUE_KEY] = min_value
	if max_value != 0:
		output[_MAX_VALUE_KEY] = max_value
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _MIN_VALUE_KEY):
		min_value = ParseUtils.dictionary_int(raw_dict, _MIN_VALUE_KEY)
	else:
		min_value = 0

	if ParseUtils.dictionary_has_number(raw_dict, _MAX_VALUE_KEY):
		max_value = ParseUtils.dictionary_int(raw_dict, _MAX_VALUE_KEY)
	else:
		max_value = 0

	if min_value > max_value:
		max_value = min_value
