extends PlayerAI
class_name TestAI1

func play(provinces:Array):
	# Obtain a list of all of your armies
	# (This must be done in a separate loop,
	# otherwise some armies might be moved more than once)
	var province_armies = []
	for province in provinces:
		province_armies.append(province.get_node("Armies").get_armies_of(playing_country))
	
	# Move each army to a designated target
	var number_of_provinces = provinces.size()
	for i in number_of_provinces:
		var links = []
		for link in provinces[i].links:
			links.append([link])
		for army in province_armies[i]:
			find_target_province(links, army, provinces[i], 0)

# Links here take the form of [[p1, p2], [p3, p4], ...]
# where p1, p3 are direct links, p2 and p4 are links of the links, etc.
# In this case, p2 is a link of p1 and p4 is a link of p3.
# (This is a recursive function.)
func find_target_province(links, army:Army, province:Province, c:int):
	# Prevent infinite loop if it's impossible to find a target to capture
	if c>=100:
		return
	# Get a list of all the provinces you don't own
	var targets = []
	for link in links:
		var furthest_link = link.size() - 1
		if link[furthest_link].owner_country != playing_country:
			targets.append(link)
	var number_of_targets = targets.size()
	# If there's any, send troops evenly to each province
	if number_of_targets > 0:
		# Split the troops evenly
		# If there's more targets than available troops, don't split at all
		@warning_ignore("integer_division")
		var troops_to_send:int = army.troop_count / number_of_targets
		if troops_to_send > 0:
			var partition = []
			for t in targets:
				partition.append(troops_to_send)
			partition[0] += army.troop_count % number_of_targets
			var action_split = ActionArmySplit.new(army, province, partition)
			# TODO refactor
			# Note: this is fine. Later the code will be rewritten so that
			# the AI will only create the actions (and not play them).
			# Connecting actions to the Rules node will be done from the Game script.
			get_parent().get_parent().get_node("Rules").connect_action(action_split)
			action_split.play_action()
		# Get all the armies and move them
		var armies_in_province = province.get_node("Armies").get_armies_of(playing_country)
		var number_of_armies = armies_in_province.size()
		for i in number_of_armies:
			var action_move = ActionArmyMovement.new(armies_in_province[i], targets[i][0])
			# TODO refactor
			get_parent().get_parent().get_node("Rules").connect_action(action_move)
			action_move.play_action()
	else:
		# Build new links
		var new_links = []
		# Make a list of all the provinces we've already searched
		var already_searched_provinces = [province]
		for link in links:
			for l in link:
				if already_searched_provinces.find(l) == -1:
					already_searched_provinces.append(l)
		# Get the linked provinces that have not been searched yet
		for link in links:
			var furthest_link = link.size() - 1
			var next_links = link[furthest_link].links
			for next_link in next_links:
				if already_searched_provinces.find(next_link) == -1:
					var link_appended = link.duplicate()
					link_appended.append(next_link)
					new_links.append(link_appended)
					already_searched_provinces.append(next_link)
		# Find a province further away
		find_target_province(new_links, army, province, c + 1)
