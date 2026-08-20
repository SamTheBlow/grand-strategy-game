class_name TurnParsing
## Parses raw data from/to a [GameTurn].

const _TURN_KEY: String = "turn"
const _COUNTRY_ID_KEY: String = "playing_country_id"


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_data(raw_data: Variant) -> ParseResult:
	var output := ParseResult.new()

	if raw_data is not Dictionary:
		return output
	var raw_dict: Dictionary = raw_data

	# Turn
	if ParseUtils.dictionary_has_number(raw_dict, _TURN_KEY):
		output.turn = maxi(1, ParseUtils.dictionary_int(raw_dict, _TURN_KEY))

	# Playing country id
	if ParseUtils.dictionary_has_number(raw_dict, _COUNTRY_ID_KEY):
		output.playing_country_id = (
				ParseUtils.dictionary_int(raw_dict, _COUNTRY_ID_KEY)
		)

	return output


static func to_raw_dict(turn: GameTurn) -> Dictionary:
	var output: Dictionary = {
		_TURN_KEY: turn.current_turn(),
		_COUNTRY_ID_KEY: turn._playing_country_id,
	}

	if turn.current_turn() == 1:
		output.erase(_TURN_KEY)
	if turn._playing_country_id == -1:
		output.erase(_COUNTRY_ID_KEY)

	return output


class ParseResult:
	var turn: int = 1
	var playing_country_id: int = -1

	func game_turn(game: Game) -> GameTurn:
		return GameTurn.new(game, turn, playing_country_id)
