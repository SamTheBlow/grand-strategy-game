class_name Rule
extends Node


signal game_over(winner: Country)

## A list of every signal this rule would like to listen to.
## Each element is an array of size 3: [rule_name, signal_name, method_name]
## This array should be setup as soon as the node is created
var listen_to: Array = []


func _on_start_of_turn(_game_state: GameState) -> void:
	pass


func action_is_legal(_game_state: GameState, _action: Action) -> bool:
	return true


# TODO this is not really the best place for this...
# Counts how many provinces each country has
func province_count_per_country(provinces: Array[Province]) -> Array:
	var output: Array = []
	
	for province in provinces:
		if not province.has_owner_country():
			continue
		
		# Find the country on our list
		var index: int = -1
		var output_size: int = output.size()
		for i in output_size:
			if output[i][0] == province.owner_country():
				index = i
				break
		
		# It isn't on our list. Add it
		if index == -1:
			output.append([province.owner_country(), 1])
		# It is on our list. Increase its number of owned provinces
		else:
			output[index][1] += 1
	
	return output


func declare_game_over(winner: Country) -> void:
	game_over.emit(winner)
