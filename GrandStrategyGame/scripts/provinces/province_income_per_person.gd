class_name ProvinceIncomePerPerson
## Class responsible for updating a province's income depending on population.


func update_province(province: Province) -> void:
	if (
		province.game.rules.province_income_option
		== GameRules.ProvinceIncome.POPULATION
	):
		province.income_money = floori(
				province.game.rules.province_income_per_person
				* province.population.population_size
		)
