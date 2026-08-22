class_name ProvinceConstantIncome
extends GameComponent
## On each turn, gives each province's money income to its country.

const KEY: String = "province_constant_income"
const TITLE: String = "Province Constant Income"
const DESCRIPTION: String = "On each turn, gives each province's money income to its country."
const SETTINGS: Array = []


func _init() -> void:
	priority_index = 12


func register(game: Game) -> void:
	game.turn.turn_changed.connect(_apply.bind(game).unbind(1))


func _apply(game: Game) -> void:
	for province in game.world.provinces.list:
		if province.owner_country == null:
			continue
		province.owner_country.money += province.money_income().value
