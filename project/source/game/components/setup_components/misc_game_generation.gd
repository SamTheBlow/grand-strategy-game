class_name MiscGameGeneration
extends GameComponent
## Applies various changes to the game's provinces.

const ID: int = 1

const _RANDOMIZE_POPULATION_KEY: String = "randomize_population"
const _EXTRA_POPULATION_KEY: String = "extra_starting_population"
const _START_WITH_FORTRESS_KEY: String = "start_with_fortress"
const _STARTING_ARMY_SIZE_KEY: String = "starting_army_size"

var _already_supplied_countries: Array[Country] = []

var _is_population_randomized: bool = false
var _extra_starting_population: int = 0
var _is_starting_fortress_enabled: bool = false
var _starting_army_size: int = 0


func _init() -> void:
	priority_index = 100


func id() -> int:
	return ID


func run(game: Game) -> void:
	_already_supplied_countries.clear()

	for province in game.world.provinces.list():
		var is_starting_province: bool = province.owner_country != null

		# Randomize population size
		if _is_population_randomized:
			var exponential_rng: float = game.rng.randf() ** 2.0
			province.population().value = floori(exponential_rng * 1000.0)

		# Add extra starting population
		if is_starting_province:
			province.population().value += _extra_starting_population

		# Overwrite money income
		if game.rules.province_income_override_enabled.value:
			province.base_money_income().value = _province_base_income(game)

		# Add starting fortress
		if (
				_is_starting_fortress_enabled and is_starting_province
				and province.buildings.list().is_empty()
		):
			province.buildings.add(
					Building.new(game.world.fortress_data(), province.id)
			)

		# Add starting army
		if (
				_starting_army_size >= game.rules.minimum_army_size.value
				and is_starting_province
				and province.owner_country not in _already_supplied_countries
		):
			Army.Factory.new(game).new_army(
					province.owner_country, province.id, _starting_army_size
			)
			_already_supplied_countries.append(province.owner_country)


func to_raw_data() -> Dictionary:
	var output: Dictionary = { _ID_KEY: ID }
	if _is_population_randomized:
		output[_RANDOMIZE_POPULATION_KEY] = _is_population_randomized
	if _extra_starting_population != 0:
		output[_EXTRA_POPULATION_KEY] = _extra_starting_population
	if _is_starting_fortress_enabled:
		output[_START_WITH_FORTRESS_KEY] = _is_starting_fortress_enabled
	if _starting_army_size != 0:
		output[_STARTING_ARMY_SIZE_KEY] = _starting_army_size
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_bool(raw_dict, _RANDOMIZE_POPULATION_KEY):
		_is_population_randomized = raw_dict[_RANDOMIZE_POPULATION_KEY] as bool
	else:
		_is_population_randomized = false

	if ParseUtils.dictionary_has_number(raw_dict, _EXTRA_POPULATION_KEY):
		_extra_starting_population = (
				ParseUtils.dictionary_int(raw_dict, _EXTRA_POPULATION_KEY)
		)
	else:
		_extra_starting_population = 0

	if ParseUtils.dictionary_has_bool(raw_dict, _START_WITH_FORTRESS_KEY):
		_is_starting_fortress_enabled = (
				raw_dict[_START_WITH_FORTRESS_KEY] as bool
		)
	else:
		_is_starting_fortress_enabled = false

	if ParseUtils.dictionary_has_number(raw_dict, _STARTING_ARMY_SIZE_KEY):
		_starting_army_size = (
				ParseUtils.dictionary_int(raw_dict, _STARTING_ARMY_SIZE_KEY)
		)
	else:
		_starting_army_size = 0

	error = false
	error_message = ""


## Returns province income according to the game rules.
func _province_base_income(game: Game) -> int:
	match game.rules.province_income_option.selected_value():
		GameRules.ProvinceIncome.RANDOM:
			return game.rng.randi_range(
					game.rules.province_income_random_min.value,
					game.rules.province_income_random_max.value
			)
		GameRules.ProvinceIncome.CONSTANT:
			return game.rules.province_income_constant.value
		_:
			return 0
