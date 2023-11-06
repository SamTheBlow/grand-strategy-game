class_name RuleProvincePercentageToWin
extends Rule


@export_range(0.0, 100.0, 0.1) var percentage_to_win: float = 70.0


func _on_start_of_turn(game_state: GameState) -> void:
	var provinces_node: Provinces = game_state.world.provinces
	var province_nodes: Array[Province] = provinces_node.get_provinces()
	
	# Get how many provinces each country has
	var ownership: Array = province_count_per_country(province_nodes)
	
	# Declare a winner if there is one
	var number_of_provinces: int = province_nodes.size()
	for o in ownership:
		if float(o[1]) / number_of_provinces >= percentage_to_win * 0.01:
			declare_game_over(o[0])
			break
