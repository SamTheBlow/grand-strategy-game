class_name TurnLimit
extends GameComponent
## Ends the game once the final turn ends.

const KEY: String = "turn_limit"

const _FINAL_TURN_KEY: String = "final_turn"

## The last turn that can be played. The game ends at the end of that turn.
var final_turn: int = 1


func _init(initial_final_turn: int = 1) -> void:
	priority_index = 0
	final_turn = initial_final_turn


func register(game: Game) -> void:
	game.turn.turn_changed.connect(_on_new_turn.bind(game))


func to_raw_dict() -> Dictionary:
	return { _FINAL_TURN_KEY: final_turn }


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _FINAL_TURN_KEY):
		final_turn = ParseUtils.dictionary_int(raw_dict, _FINAL_TURN_KEY)
	else:
		final_turn = 1

	error = false
	error_message = ""


func _on_new_turn(turn_number: int, game: Game) -> void:
	if turn_number > final_turn:
		game.end_game()
