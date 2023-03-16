extends Rule
class_name RuleTurnLimit

@export var final_turn:int = 10

func _on_start_of_turn(provinces, current_turn:int):
	if current_turn <= final_turn:
		return
	
	# Get how many provinces each country has
	var ownership:Array = province_count_per_country(provinces)
	
	# Find which player has the most provinces
	var winning_player_index:int = 0
	var number_of_players = ownership.size()
	for i in number_of_players:
		if ownership[i][1] > ownership[winning_player_index][1]:
			winning_player_index = i
	
	# End the game
	declare_game_over(ownership[winning_player_index][0])
