class_name IncomeMoneyPerPopulation
extends IncomeMoney.IncomeMoneyAlgorithm

var _population: Population
var _income_per_person: float


func _init(population: Population, income_per_person: float) -> void:
	_population = population
	_income_per_person = income_per_person
	_population.size_changed.connect(_on_population_size_changed)
	_update_amount()


func _update_amount() -> void:
	_amount = floori(_income_per_person * _population.population_size)


func _on_population_size_changed(_new_value: int) -> void:
	_update_amount()
