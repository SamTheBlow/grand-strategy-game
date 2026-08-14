class_name ProvinceConstantIncome
extends GameComponent
## Each turn, gives to the owner of each [Province]
## a constant money income according to the province's value.

const KEY: String = "province_constant_income"


func _init() -> void:
	priority_index = 12


func register(game: Game) -> void:
	game.turn.turn_changed.connect(
			_apply_income.bind(game.world.provinces).unbind(1)
	)


func _apply_income(provinces: Provinces) -> void:
	for province in provinces.list():
		if province.owner_country == null:
			continue
		province.owner_country.money += province.money_income().value
