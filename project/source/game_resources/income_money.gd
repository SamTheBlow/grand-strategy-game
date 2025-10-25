class_name IncomeMoney
## Provides information on how much money is generated.

signal amount_changed(new_amount: int)

var _algorithm: IncomeMoneyAlgorithm


func _init(rules: GameRules, province: Province) -> void:
	if rules.province_income_override_enabled.value:
		match rules.province_income_option.selected_value():
			GameRules.ProvinceIncome.POPULATION:
				_algorithm = IncomeMoneyPerPopulation.new(
						province.population(),
						rules.province_income_per_person.value
				)
			_:
				_algorithm = IncomeMoneyConstant.new(
						province.base_money_income()
				)
	else:
		_algorithm = IncomeMoneyConstant.new(province.base_money_income())

	_algorithm.amount_changed.connect(amount_changed.emit)


func amount() -> int:
	return _algorithm.amount()


@abstract class IncomeMoneyAlgorithm:
	signal amount_changed(new_amount: int)

	@abstract func amount() -> int

class IncomeMoneyConstant extends IncomeMoneyAlgorithm:
	var _amount: IntWithSignals

	func _init(base_income := IntWithSignals.new()) -> void:
		_amount = base_income
		_amount.value_changed.connect(amount_changed.emit)

	func amount() -> int:
		return _amount.value

class IncomeMoneyPerPopulation extends IncomeMoneyAlgorithm:
	var _population: IntWithSignals
	var _income_per_person: float
	var _amount: int = 0

	func _init(population: IntWithSignals, income_per_person: float) -> void:
		_population = population
		_income_per_person = income_per_person
		_update_amount()
		_population.value_changed.connect(_on_population_size_changed)

	func amount() -> int:
		return _amount

	func _update_amount() -> void:
		_amount = floori(_income_per_person * _population.value)

	func _on_population_size_changed(_value: int) -> void:
		var _previous_amount: int = _amount
		_update_amount()
		if _amount != _previous_amount:
			amount_changed.emit(_amount)
