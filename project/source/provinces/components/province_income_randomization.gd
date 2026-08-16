class_name ProvinceIncomeRandomization
extends GameComponent
## During game setup, randomizes the money income of each [Province].

const KEY: String = "province_income_randomization"

const _RANDOM_MIN_KEY: String = "random_min"
const _RANDOM_MAX_KEY: String = "random_max"

var random_min: int = 0
var random_max: int = 0


func _init() -> void:
	priority_index = 5


func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	for province in game.world.provinces.list:
		province.money_income().value = (
				game.rng.randi_range(random_min, random_max)
		)


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if random_min != 0:
		output[_RANDOM_MIN_KEY] = random_min
	if random_max != 0:
		output[_RANDOM_MAX_KEY] = random_max
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _RANDOM_MIN_KEY):
		random_min = ParseUtils.dictionary_int(raw_dict, _RANDOM_MIN_KEY)
	else:
		random_min = 0

	if ParseUtils.dictionary_has_number(raw_dict, _RANDOM_MAX_KEY):
		random_max = ParseUtils.dictionary_int(raw_dict, _RANDOM_MAX_KEY)
	else:
		random_max = 0

	if random_min > random_max:
		random_max = random_min

	error = false
	error_message = ""
