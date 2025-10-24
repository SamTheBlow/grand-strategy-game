class_name IncomeEachTurn
## Gives to the owner country of given province the province's money income.


static func apply(province: Province) -> void:
	if province.owner_country != null:
		province.owner_country.money += province.income_money.amount()
