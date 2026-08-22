class_name ProvincePopulationIncome
extends GameComponent
## On each turn, gives to each province's country
## a money income proportional to the population size.

const KEY: String = "province_population_income"
const TITLE: String = "Province Population Income"
const DESCRIPTION: String = "On each turn, gives to each province's country a money income proportional to the population size."
const SETTINGS: Array = [
	{ "property_name": _PER_PERSON_KEY, "text": "Income per person", "type": "float" },
]

const _PER_PERSON_KEY: String = "per_person"

var per_person: float = 0.0


func _init() -> void:
	priority_index = 12


func register(game: Game) -> void:
	game.turn.turn_changed.connect(_apply.bind(game).unbind(1))


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


func _apply(game: Game) -> void:
	for province in game.world.provinces.list:
		if province.owner_country == null:
			continue
		province.owner_country.money += amount_for(province)
