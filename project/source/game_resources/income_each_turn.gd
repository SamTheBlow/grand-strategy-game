class_name IncomeEachTurn
## Gives the owner of given [Province] extra money on each new turn.

var _province: Province


func _init(province: Province, turn_changed: Signal) -> void:
	_province = province
	turn_changed.connect(_on_turn_changed)


func _on_turn_changed(_turn: int) -> void:
	if _province == null or _province.owner_country == null:
		return

	_province.owner_country.money += _province.income_money().total()
