class_name ActionAdvanceRNG
extends Action
## Advances the game's RNG state by given number of steps.
## Useful to keep RNG in sync when an AI uses RNG.

const _COUNT_KEY: String = "count"

var _step_count: int


func _init(step_count: int) -> void:
	_step_count = step_count


func apply_to(game: Game, _player: GamePlayer) -> void:
	for i in _step_count:
		game.rng.randi()


## Returns this action's raw data, for the purpose of
## transfering between network clients.
func raw_data() -> Dictionary:
	return {
		ID_KEY: ADVANCE_RNG,
		_COUNT_KEY: _step_count,
	}


## Returns an action built with given raw data.
static func from_raw_data(raw_dict: Dictionary) -> ActionAdvanceRNG:
	if not ParseUtils.dictionary_has_number(raw_dict, _COUNT_KEY):
		return null

	var step_count: int = ParseUtils.dictionary_int(raw_dict, _COUNT_KEY)

	if step_count < 1:
		return null

	return ActionAdvanceRNG.new(step_count)
