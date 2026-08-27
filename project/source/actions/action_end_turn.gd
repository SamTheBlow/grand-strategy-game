class_name ActionEndTurn
extends Action
## Ends the player's turn.


func apply_to(game: Game, player: GamePlayer) -> void:
	if player in game.turn.playing_players():
		game.turn.end_turn()
	else:
		push_warning("Tried to end someone else's turn.")


func to_raw_dict() -> Dictionary:
	return {
		_ID_KEY: END_TURN,
	}


static func from_raw_dict(_raw_dict: Dictionary) -> ActionEndTurn:
	return ActionEndTurn.new()
