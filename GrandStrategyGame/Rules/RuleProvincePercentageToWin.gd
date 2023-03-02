extends Rule
class_name RuleProvincePercentageToWin

var percentage_to_win:float = 70.0

func _on_start_of_turn(provinces, _current_turn:int):
	# Get how many provinces each country has
	var ownership = province_count_per_country(provinces)
	
	# Declare a winner if there is one
	var number_of_provinces = provinces.size()
	for o in ownership:
		if float(o[1]) / number_of_provinces >= percentage_to_win * 0.01:
			game_over(o[0])
			break
