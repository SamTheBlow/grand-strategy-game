class_name ActionEndTurn
extends Action


func apply_to(game: Game, player: GamePlayer) -> void:
	if game.turn.playing_player() == player:
		game.turn.end_turn()
	else:
		print_debug("Tried to end someone else's turn.")


## Returns this action's raw data, for the purpose of
## transfering between network clients.
func raw_data() -> Dictionary:
	return {
		"id": END_TURN,
	}


## Returns an action built with given raw data.
static func from_raw_data(_data: Dictionary) -> ActionEndTurn:
	return ActionEndTurn.new()
