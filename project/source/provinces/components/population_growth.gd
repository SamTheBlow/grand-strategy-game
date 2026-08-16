class_name PopulationGrowth
extends GameComponent
## Makes populations grow on each new turn.

const KEY: String = "population_growth"

const _GROWTH_RATE_KEY: String = "growth_rate"

## For reference...
## - Negative values have no effect
## - 0.0 adds 1 population
## - 1.0 doubles population
var _growth_rate: float = 0.0


func _init() -> void:
	priority_index = 11


func register(game: Game) -> void:
	game.turn.turn_changed.connect(_apply.bind(game).unbind(1))


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if _growth_rate != 0.0:
		output[_GROWTH_RATE_KEY] = _growth_rate
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _GROWTH_RATE_KEY):
		_growth_rate = ParseUtils.dictionary_float(raw_dict, _GROWTH_RATE_KEY)
	else:
		_growth_rate = 0.0

	error = false
	error_message = ""


func _apply(game: Game) -> void:
	for province in game.world.provinces.list:
		if _growth_rate == 0.0 or province.population().value == 0:
			continue
		province.population().value += int(
				province.population().value ** _growth_rate
		)
