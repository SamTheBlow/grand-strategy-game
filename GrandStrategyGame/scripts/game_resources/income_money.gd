class_name IncomeMoney
## Class responsible for money income in given province.


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
		_province.game.rules.province_income_option
		== GameRules.ProvinceIncome.POPULATION
	):
		total_income += floori(
				_province.game.rules.province_income_per_person
				* _province.population.population_size
		)
	return total_income


func _on_population_size_changed(_new_value: int) -> void:
	if (
		_province.game.rules.province_income_option
		== GameRules.ProvinceIncome.POPULATION
	):
		changed.emit(total())
