class_name ArmyRecruitment
extends GameComponent
## Enables army recruitment. Holds relevant settings.

const KEY: String = "army_recruitment"

const _MONEY_PER_UNIT_KEY: String = "money_per_unit"
const _POPULATION_PER_UNIT_KEY: String = "population_per_unit"

## How much money it costs to recruit a single troop.
var money_per_unit: float = 0.0

## How much population it costs to recruit a single troop.
var population_per_unit: float = 0.0


func _init() -> void:
	priority_index = 0


func register(_game: Game) -> void:
	pass


## May return null, in which case given game doesn't have recruitment.
static func in_game(game: Game) -> ArmyRecruitment:
	return game.components.get(KEY) as ArmyRecruitment


## How much in-game money it would cost to recruit given troop count.
func money_cost(troop_count: int) -> int:
	return ResourceCost.new("Money", money_per_unit).cost_fori(troop_count)


## How much [Population] it would cost to recruit given troop count.
func population_cost(troop_count: int) -> int:
	return (
			ResourceCost.new("Population", population_per_unit)
			.cost_fori(troop_count)
	)


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if money_per_unit != 0.0:
		output[_MONEY_PER_UNIT_KEY] = money_per_unit
	if population_per_unit != 0.0:
		output[_POPULATION_PER_UNIT_KEY] = population_per_unit
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _MONEY_PER_UNIT_KEY):
		money_per_unit = ParseUtils.dictionary_float(
				raw_dict, _MONEY_PER_UNIT_KEY
		)
	else:
		money_per_unit = 0.0

	if ParseUtils.dictionary_has_number(raw_dict, _POPULATION_PER_UNIT_KEY):
		population_per_unit = ParseUtils.dictionary_float(
				raw_dict, _POPULATION_PER_UNIT_KEY
		)
	else:
		population_per_unit = 0.0
