class_name RuleMinArmySize
extends Rule
## Getting rid of this class (WIP)


# Prevent players from creating armies that are too small
func action_is_legal(_game_state: GameState, action: Action) -> bool:
	if action is ActionArmySplit:
		var action_split := action as ActionArmySplit
		var partition: Array[int] = action_split._troop_partition
		for p in partition:
			if p < 10:
				push_warning(
						"Tried to split an army, but at least one"
						+ " of the resulting armies was too small!"
				)
				return false
	return true
