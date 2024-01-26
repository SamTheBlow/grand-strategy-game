class_name Action
extends Node
## An abstract class for actions.
## Actions are the things players do that affect the game state.


func apply_to(
		_game_mediator: GameMediator,
		_game_state: GameState,
		_is_simulation: bool
) -> void:
	pass
