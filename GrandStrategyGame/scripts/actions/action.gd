class_name Action
extends Node
## An abstract class for actions.
## Actions are the things players do that affect the game state.


## Takes in the current game as well as the player trying to apply the action.
func apply_to(_game: Game, _player: Player) -> void:
	pass
