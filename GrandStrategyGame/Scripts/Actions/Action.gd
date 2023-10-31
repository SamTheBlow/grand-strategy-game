class_name Action
extends Node
## An abstract class for actions.
## Actions are the things players do that affect the game state.


signal action_applied


## When processing an action, it is always assumed that it is a legal action.
## Therefore, please check that the action is legal before processing it.
func apply_to(game_state: GameState) -> void:
	emit_signal("action_applied", self, game_state)


func update_visuals(_provinces_node: Provinces, _is_simulation: bool) -> void:
	pass
