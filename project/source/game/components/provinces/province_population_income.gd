class_name ProvincePopulationIncome
extends GameComponent
## Each turn, gives to the owner of each [Province]
## a money income proportional to the province's population size.

const KEY: String = "province_population_income"

const _PER_PERSON_KEY: String = "per_person"

var per_person: float = 0.0


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
		province.owner_country.money += amount_for(province)


## The amount of money this province generates each turn,
## based on its population.
func amount_for(province: Province) -> int:
	return floori(per_person * province.population().value)


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if per_person != 0.0:
		output[_PER_PERSON_KEY] = per_person
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _PER_PERSON_KEY):
		per_person = ParseUtils.dictionary_float(raw_dict, _PER_PERSON_KEY)
	else:
		per_person = 0.0

	error = false
	error_message = ""
