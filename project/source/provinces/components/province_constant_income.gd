class_name ProvinceConstantIncome
extends GameComponent
## Each turn, gives to the owner of each [Province]
## a constant money income according to the province's value.

const KEY: String = "province_constant_income"


func _init() -> void:
	priority_index = 12


func register(game: Game) -> void:
	game.turn_change_iteration.turn_changed_province.connect(_apply_to_province)


func _apply_to_province(province: Province) -> void:
	if province.owner_country == null:
		return
	province.owner_country.money += province.money_income().value
