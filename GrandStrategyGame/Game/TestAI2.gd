class_name TestAI2
extends PlayerAI
# Test AI. Always tries to move its armies to the nearest targets.
# It also leaves some troops idle to defend.


func play(provinces: Array[Province]):
	# Obtain a list of all of your armies
	# (This must be done in a separate loop,
	# otherwise some armies might be moved more than once)
	var province_armies: Array = []
	for province in provinces:
		var armies_node := province.get_node("Armies") as Armies
		province_armies.append(armies_node.get_armies_of(playing_country))
	
	# Move each army to a designated target
	var movements: Array[ActionArmyMovement] = []
	var number_of_provinces: int = provinces.size()
	for i in number_of_provinces:
		var links: Array = []
		for link in provinces[i].links:
			links.append([link])
		
		var armies := province_armies[i] as Array[Army]
		for army in armies:
			movements.append_array(
				find_target_province(links, army, provinces[i], 0)
			)
	
	# Play out all of the actions (temporary)
	for movement in movements:
		movement.play_action()


# Links here take the form of [[p1, p2], [p3, p4], ...]
# where p1, p3 are direct links, p2 and p4 are links of the links, etc.
# In this case, p2 is a link of p1 and p4 is a link of p3.
# (This is a recursive function.)
func find_target_province(
	links: Array, army: Army, province: Province, c: int
) -> Array[ActionArmyMovement]:
	var movements: Array[ActionArmyMovement] = []
	
	# Prevent infinite loop if it's impossible to find a target to capture
	if c >= 100:
		return []
	
	# Get a list of all the provinces you don't own
	var targets: Array = []
	for link in links:
		var furthest_link: int = link.size() - 1
		if link[furthest_link].owner_country != playing_country:
			targets.append(link)
	
	# If there's any, send troops evenly to each province
	var number_of_targets: int = targets.size()
	if number_of_targets > 0:
		# Split the troops evenly
		# If there's more targets than available troops, don't split at all
		@warning_ignore("integer_division")
		var troops_to_send: int = army.troop_count / (number_of_targets + 1)
		if troops_to_send > 0:
			var partition: Array = []
			partition.append(troops_to_send)
			for target in targets:
				partition.append(troops_to_send)
			partition[0] += army.troop_count % (number_of_targets + 1)
			var action_split := ActionArmySplit.new(army, province, partition)
			# TODO refactor
			# Note: this is fine. Later the code will be rewritten so that
			# the AI will only create the actions (and not play them).
			# Connecting actions to the Rules node will be done from the Game script.
			get_parent().get_parent().get_node("Rules").connect_action(action_split)
			action_split.play_action()
		
		# Get all the armies and move them
		var armies_node := province.get_node("Armies") as Armies
		var armies_in_province: Array[Army] = (
			armies_node.get_armies_of(playing_country)
		)
		var number_of_armies_to_move: int = armies_in_province.size() - 1
		for i in number_of_armies_to_move:
			var action_move := ActionArmyMovement.new(
				armies_in_province[i + 1], targets[i][0]
			)
			# TODO refactor
			get_parent().get_parent().get_node("Rules").connect_action(action_move)
			movements.append(action_move)
	else:
		# Build new links
		var new_links: Array = []
		# Make a list of all the provinces we've already searched
		var already_searched_provinces: Array[Province] = [province]
		for link in links:
			for l in link:
				if already_searched_provinces.find(l) == -1:
					already_searched_provinces.append(l)
		# Get the linked provinces that have not been searched yet
		for link in links:
			var furthest_link: int = link.size() - 1
			var next_links: Array = link[furthest_link].links
			for next_link in next_links:
				if already_searched_provinces.find(next_link) == -1:
					var link_appended: Array = link.duplicate()
					link_appended.append(next_link)
					new_links.append(link_appended)
					already_searched_provinces.append(next_link)
		# Find a province further away
		movements = find_target_province(new_links, army, province, c + 1)
	return movements
