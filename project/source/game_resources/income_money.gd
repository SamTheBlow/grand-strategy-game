class_name IncomeMoney
## Provides information on how much money a [Province] generates every turn,
## as the sum of all the active money-income components' contributions.
##
## WARNING:
## This is not meant to be used before the game has been setup for playing.

signal amount_changed(new_amount: int)

var _algorithms: Array[IncomeMoneyAlgorithm] = []
var _total: int = 0


func _init(game: Game, province: Province) -> void:
	if game.components.has(ProvinceConstantIncome.KEY):
		_algorithms.append(IncomeMoneyConstant.new(province.money_income()))

	if game.components.has(ProvincePopulationIncome.KEY):
		var population_income := (
				game.components.get(ProvincePopulationIncome.KEY)
				as ProvincePopulationIncome
		)
		_algorithms.append(IncomeMoneyPerPopulation.new(
				province.population(), population_income.per_person
		))

	_update_total()
	for algorithm in _algorithms:
		algorithm.amount_changed.connect(_update_total)


func amount() -> int:
	return _total


func _update_total() -> void:
	var new_total: int = 0
	for algorithm in _algorithms:
		new_total += algorithm.amount()
	if new_total != _total:
		_total = new_total
		amount_changed.emit(_total)


@abstract class IncomeMoneyAlgorithm:
	signal amount_changed()

	@abstract func amount() -> int


class IncomeMoneyConstant extends IncomeMoneyAlgorithm:
	var _amount: IntWithSignals

	func _init(base_income := IntWithSignals.new()) -> void:
		_amount = base_income
		_amount.value_changed.connect(amount_changed.emit.unbind(1))

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
			amount_changed.emit()
