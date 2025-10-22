class_name IncomeEachTurn
## On a new turn, gives to each [Country] the money income
## from each [Province] they control.

## Effect does not trigger while disabled.
var is_enabled: bool = false:
	set(value):
		if value == is_enabled:
			return
		is_enabled = value
		if is_enabled:
			_game.turn.turn_changed.connect(_on_turn_changed)
		else:
			_game.turn.turn_changed.disconnect(_on_turn_changed)

var _game: Game


func _init(game: Game) -> void:
	_game = game
	is_enabled = true


func _give_money_income() -> void:
	for province in _game.world.provinces.list():
		if province.owner_country != null:
			province.owner_country.money += province.income_money.amount()


func _on_turn_changed(_turn: int) -> void:
	_give_money_income()
