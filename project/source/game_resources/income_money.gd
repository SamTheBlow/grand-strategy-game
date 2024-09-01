class_name IncomeMoney
## Class responsible for the money income in given [Province].
## Provides information on how much money the province generates per turn.
## 
## See also: [GameTurn]


# TODO There are cases where this is emitted even though the value didn't change.
# For example, if the income per person is 0.1, and the population
# changes from 2 to 3, then the game calls _on_population_size_changed
# and emits this signal with the new total, even though the income is still 0.
# Before the population change: floori(0.1 * 2) = 0
# After the population change: floori(0.1 * 3) = 0
signal changed(new_value: int)

var base_income: int = 0:
	set(value):
		base_income = value
		changed.emit(total())

var _province: Province


func _init(base_income_: int, province: Province) -> void:
	_province = province
	base_income = base_income_
	province.population.size_changed.connect(_on_population_size_changed)


func total() -> int:
	var total_income: int = base_income
	if (
			_province.game.rules.province_income_option.selected
			== GameRules.ProvinceIncome.POPULATION
	):
		total_income += floori(
				_province.game.rules.province_income_per_person.value
				* _province.population.population_size
		)
	return total_income


func _on_population_size_changed(_new_value: int) -> void:
	if (
		_province.game.rules.province_income_option.selected
		== GameRules.ProvinceIncome.POPULATION
	):
		changed.emit(total())
