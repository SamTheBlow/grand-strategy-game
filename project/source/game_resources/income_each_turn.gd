class_name IncomeEachTurn
## Gives to the owner country of given province the province's money income.


static func apply(rules: GameRules, province: Province) -> void:
	if province.owner_country == null:
		return
	province.owner_country.money += IncomeMoney.new(rules, province).amount()
