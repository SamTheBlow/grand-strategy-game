class_name TurnParsing
## Parses raw data from/to a [GameTurn].

const _TURN_KEY: String = "turn"
const _PLAYER_INDEX_KEY: String = "playing_player_index"


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_data(raw_data: Variant) -> ParseResult:
	var output := ParseResult.new()
	
	if raw_data is not Dictionary:
		return output
	var raw_dict: Dictionary = raw_data

	# Turn
	if ParseUtils.dictionary_has_number(raw_dict, _TURN_KEY):
		output.turn = ParseUtils.dictionary_int(raw_dict, _TURN_KEY)

	# Playing player index
	if ParseUtils.dictionary_has_number(raw_dict, _PLAYER_INDEX_KEY):
		output.playing_player_index = (
				ParseUtils.dictionary_int(raw_dict, _PLAYER_INDEX_KEY)
		)

	return output


static func to_raw_dict(turn: GameTurn) -> Dictionary:
	var output: Dictionary = {
		_TURN_KEY: turn.current_turn(),
		_PLAYER_INDEX_KEY: turn._playing_player_index,
	}

	if turn.current_turn() == 1:
		output.erase(_TURN_KEY)
	if turn._playing_player_index == 0:
		output.erase(_PLAYER_INDEX_KEY)

	return output


class ParseResult:
	var turn: int = 1
	var playing_player_index: int = 0

	func game_turn(game: Game) -> GameTurn:
		return GameTurn.new(game, turn, playing_player_index)
