extends Node

signal game_over

var percentage_to_win = 70

func _start_of_turn(provinces):
	var number_of_provinces = provinces.size()
	var ownership = []
	for p in provinces:
		if p.owner_country != null:
			# Find the country on our list
			var index = -1
			var ownership_size = ownership.size()
			for i in ownership_size:
				if ownership[i][0] == p.owner_country:
					index = i
					break
			# It isn't on our list. Add it
			if index == -1:
				ownership.append([p.owner_country, 1])
			# It is on our list. Increase its number of owned provinces
			else:
				ownership[index][1] += 1
	# Declare a winner if there is one
	for o in ownership:
		if float(o[1]) / number_of_provinces >= percentage_to_win * 0.01:
			emit_signal("game_over", o[0])
			break
