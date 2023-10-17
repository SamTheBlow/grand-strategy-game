class_name RuleTurnLimit
extends Rule


@export var final_turn: int = 10


func _on_start_of_turn(game_state: GameState) -> void:
	var current_turn: int = game_state.data().get_int("turn").data
	
	if current_turn <= final_turn:
		return
	
	# Get how many provinces each country has
	var provinces_node: Provinces = (
			get_parent().get_parent().get_node("Provinces") as Provinces
	)
	var province_nodes: Array[Province] = provinces_node.get_provinces()
	var ownership: Array = province_count_per_country(province_nodes)
	
	# Find which player has the most provinces
	var winning_player_index: int = 0
	var number_of_players: int = ownership.size()
	for i in number_of_players:
		if ownership[i][1] > ownership[winning_player_index][1]:
			winning_player_index = i
	
	# End the game
	declare_game_over(ownership[winning_player_index][0])
