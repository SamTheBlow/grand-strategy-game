class_name TurnLimit
extends GameComponent
## Ends the game once the final turn ends.

const KEY: String = "turn_limit"
const TITLE: String = "Turn Limit"
const DESCRIPTION: String = "Ends the game once the final turn ends."
const SETTINGS: Array = [
	{ "property_name": _FINAL_TURN_KEY, "text": "Final turn", "type": "int", "min": 1 },
]

const _FINAL_TURN_KEY: String = "final_turn"

## The last turn that can be played. The game ends at the end of that turn.
var final_turn: int = 1


func _init(initial_final_turn: int = 1) -> void:
	priority_index = 0
	final_turn = initial_final_turn


func register(game: Game) -> void:
	game.turn.started.connect(_check.bind(game))
	game.turn.turn_changed.connect(_check.bind(game).unbind(1))


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if final_turn != 1:
		output[_FINAL_TURN_KEY] = final_turn
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _FINAL_TURN_KEY):
		final_turn = (
				maxi(1, ParseUtils.dictionary_int(raw_dict, _FINAL_TURN_KEY))
		)
	else:
		final_turn = 1


func _check(game: Game) -> void:
	if game.turn.current_turn() > final_turn:
		game.end_game()
