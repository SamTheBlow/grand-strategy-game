extends Node
class_name Rule

signal game_over

# A list of every signal this rule would like to listen to.
# Each element is an array of size 3: [rule_name, signal_name, method_name]
# This array should be setup as soon as the node is created
var listen_to:Array = []

func _on_start_of_turn(_provinces, _current_turn:int):
	pass

func _on_action_played(_action:Action):
	pass

func action_is_legal(_action:Action) -> bool:
	return true

# TODO this is not really the best place for this...
# ---> this will probably go in the GameState class or something like that.
# Count how many provinces each country has
func province_count_per_country(provinces:Array) -> Array:
	var ownership = []
	for province in provinces:
		if province.owner_country != null:
			# Find the country on our list
			var index = -1
			var ownership_size = ownership.size()
			for i in ownership_size:
				if ownership[i][0] == province.owner_country:
					index = i
					break
			# It isn't on our list. Add it
			if index == -1:
				ownership.append([province.owner_country, 1])
			# It is on our list. Increase its number of owned provinces
			else:
				ownership[index][1] += 1
	return ownership

func declare_game_over(winner:Country):
	emit_signal("game_over", winner)
