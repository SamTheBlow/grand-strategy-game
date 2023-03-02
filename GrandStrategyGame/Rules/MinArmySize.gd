extends Rule
class_name RuleMinArmySize

var minimum_army_size:int = 10

# More things could be done, like preventing human players
# from selecting too few troops for movement

# At the start of a turn, delete all insufficiently large armies
func _on_start_of_turn(provinces, _current_turn):
	for province in provinces:
		var armies = province.get_node("Armies").get_alive_armies()
		for army in armies:
			if army.troop_count < minimum_army_size:
				army.queue_free()

# Prevent players from creating armies that are too small
func action_is_legal(action:Action) -> bool:
	if action is ActionArmySplit:
		var partition = action.troop_partition
		for p in partition:
			if p < minimum_army_size:
				return false
	return true
