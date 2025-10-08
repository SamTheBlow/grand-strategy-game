class_name TurnFromRaw
## Converts raw data into a [GameTurn].
##
## This operation always succeeds.
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.

const TURN_KEY: String = "turn"
const PLAYER_INDEX_KEY: String = "playing_player_index"


static func parsed_from(raw_data: Variant) -> ParseResult:
	var output := ParseResult.new()
	
	if raw_data is not Dictionary:
		return output
	var raw_dict: Dictionary = raw_data

	# Turn
	if ParseUtils.dictionary_has_number(raw_dict, TURN_KEY):
		output.turn = ParseUtils.dictionary_int(raw_dict, TURN_KEY)

	# Playing player index
	if ParseUtils.dictionary_has_number(raw_dict, PLAYER_INDEX_KEY):
		output.playing_player_index = (
				ParseUtils.dictionary_int(raw_dict, PLAYER_INDEX_KEY)
		)

	return output


class ParseResult:
	var turn: int = 1
	var playing_player_index: int = 0

	func game_turn(game: Game) -> GameTurn:
		return GameTurn.new(game, turn, playing_player_index)
