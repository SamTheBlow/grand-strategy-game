class_name ProvinceConstantIncome
extends GameComponent
## Each turn, gives to the owner of each [Province]
## a constant money income according to the province's value.

const KEY: String = "province_constant_income"


func _init() -> void:
	priority_index = 12


func register(game: Game) -> void:
	game.turn.turn_changed.connect(_apply.bind(game).unbind(1))


func _apply(game: Game) -> void:
	for province in game.world.provinces.list:
		if province.owner_country == null:
			continue
		province.owner_country.money += province.money_income().value
