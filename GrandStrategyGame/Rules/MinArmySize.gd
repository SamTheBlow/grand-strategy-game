class_name RuleMinArmySize
extends Rule
# More things could be done, like preventing human players
# from selecting too few troops for movement


var minimum_army_size: int = 10


# At the start of a turn, delete all insufficiently large armies
func _on_start_of_turn(provinces: Array[Province], _current_turn: int):
	for province in provinces:
		var armies_node := province.get_node("Armies") as Armies
		var armies: Array[Army] = armies_node.get_alive_armies()
		for army in armies:
			if army.troop_count < minimum_army_size:
				army.queue_free()


# Prevent players from creating armies that are too small
func action_is_legal(action: Action) -> bool:
	if action is ActionArmySplit:
		var action_typed := action as ActionArmySplit
		var partition: PackedInt32Array = action_typed.troop_partition
		for p in partition:
			if p < minimum_army_size:
				return false
	return true
