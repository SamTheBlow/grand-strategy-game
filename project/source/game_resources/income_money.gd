class_name IncomeMoney
## Provides information on how much money is generated.

signal amount_changed(new_amount: int)

var _is_base_income_overwritten: bool
var _base_income: int
var _is_random: bool
var _algorithm: IncomeMoneyAlgorithm


## The parameters is_base_income_overwritten and base_income
## are to inform, in the case where it's the random option,
## that a random number was already determined.
func _init(
		game: Game,
		population: Population,
		is_base_income_overwritten: bool = false,
		base_income: int = 0
) -> void:
	_is_base_income_overwritten = is_base_income_overwritten
	_base_income = base_income
	_is_random = false

	match game.rules.province_income_option.selected_value():
		GameRules.ProvinceIncome.RANDOM:
			if not is_base_income_overwritten:
				_is_base_income_overwritten = true
				_base_income = game.rng.randi_range(
						game.rules.province_income_random_min.value,
						game.rules.province_income_random_max.value
				)
			_is_random = true
			_algorithm = IncomeMoneyConstant.new(_base_income)
		GameRules.ProvinceIncome.CONSTANT:
			_algorithm = IncomeMoneyConstant.new(
					game.rules.province_income_constant.value
			)
		GameRules.ProvinceIncome.POPULATION:
			_algorithm = IncomeMoneyPerPopulation.new(
					population, game.rules.province_income_per_person.value
			)
		_:
			push_error("Unrecognized rule.")
			_algorithm = IncomeMoneyConstant.new(0)

	_algorithm.amount_changed.connect(amount_changed.emit)


func amount() -> int:
	return _algorithm.amount()


func to_raw_dict() -> Dictionary:
	if _is_random and _is_base_income_overwritten:
		return { ProvincesFromRaw.PROVINCE_INCOME_MONEY_KEY: _base_income }
	else:
		return {}


@abstract class IncomeMoneyAlgorithm:
	signal amount_changed(new_amount: int)

	var _amount: int

	func amount() -> int:
		return _amount
