class_name Action
extends Node
## An abstract class for actions.
## Actions are the things players do that affect the game state.


signal action_applied(action: Action, game_state: GameState)


## When processing an action, it is always assumed that it is a legal action.
## Therefore, please check that the action is legal before processing it.
func apply_to(game_state: GameState) -> void:
	action_applied.emit(self, game_state)
