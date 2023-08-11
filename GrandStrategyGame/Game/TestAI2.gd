class_name TestAI2
extends PlayerAI
# Test AI. Always tries to move its armies to the nearest targets.
# It also leaves some troops idle to defend.


func play(game_state: GameState) -> Array[Action]:
	var actions: Array[Action] = []
	
	var my_country_key: String = game_state.player_country(key())
	
	var provinces: Array[GameStateData] = game_state.provinces().data()
	var number_of_provinces: int = provinces.size()
	for i in number_of_provinces:
		var province := provinces[i] as GameStateArray
		var links: Array = _new_link_tree(province)
		
		# Find the nearest target province for each of your armies
		var armies: Array[GameStateData] = (
			game_state.armies(province.get_key()).data()
		)
		for army_data in armies:
			var army := army_data as GameStateArray
			if army.get_string("owner").data == my_country_key:
				actions.append_array(
					_find_target_province(
						game_state,
						links,
						province.get_key(),
						army.get_key(),
						0
					)
				)
	
	return actions


# Links here take the form of [[p1, p2], [p3, p4], ...]
# where p1, p3 are direct links, p2 and p4 are links of the links, etc.
# In this case, p2 is a link of p1 and p4 is a link of p3.
# (This is a recursive function.)
func _find_target_province(
	game_state: GameState,
	links: Array,
	province_key: String,
	army_key: String,
	depth: int,
) -> Array[Action]:
	var actions: Array[Action] = []
	
	# Prevent infinite loop if it's impossible to find a target to capture
	if depth >= 100:
		return []
	
	# Get a list of all the provinces you don't own
	var targets: Array = []
	for link in links:
		var furthest_link: int = link.size() - 1
		var link_owner_key := String(
			game_state.province_owner(link[furthest_link]).data
		)
		if link_owner_key != playing_country.key():
			targets.append(link)
	
	# If there's any, send troops evenly to each province
	var number_of_targets: int = targets.size()
	if number_of_targets > 0:
		# Split the troops evenly
		# If there's more targets than available troops, don't split at all
		var troop_count: int = (
			game_state.army_troop_count(province_key, army_key).data
		)
		var number_of_armies: int = number_of_targets + 1
		@warning_ignore("integer_division")
		var troops_per_army: int = troop_count / number_of_armies
		
		var new_army_keys: Array[String] = []
		
		if troops_per_army >= 10:
			# Create the partition
			var troop_partition: Array[int] = []
			for i in number_of_armies:
				troop_partition.append(troops_per_army)
			troop_partition[0] += troop_count % number_of_armies
			
			# Get unique keys for the new armies
			var armies_data: GameStateArray = game_state.armies(province_key)
			new_army_keys = armies_data.new_unique_keys(number_of_targets)
			
			var action := ActionArmySplit.new(
				province_key,
				army_key,
				troop_partition,
				new_army_keys
			)
			#print("New split action created for army ", army_key, ". The new keys are: ", new_army_keys)
			actions.append(action)
		
		# Move your armies towards the targets
		var number_of_armies_to_move: int = new_army_keys.size()
		for i in number_of_armies_to_move:
			var action := ActionArmyMovement.new(
				province_key,
				new_army_keys[i],
				targets[i][0],
				game_state.armies(targets[i][0]).new_unique_key()
			)
			#print("New movement action created for army ", new_army_keys[i])
			actions.append(action)
	else:
		# Build new links
		var new_links: Array = []
		
		# Make a list of all the provinces we've already searched
		var already_searched_provinces: Array[String] = [province_key]
		for link in links:
			for l in link:
				if already_searched_provinces.find(l) == -1:
					already_searched_provinces.append(l)
		
		# Get the linked provinces that have not been searched yet
		for link in links:
			var furthest_link: int = link.size() - 1
			var next_links: Array[GameStateData] = (
				game_state.province_links(link[furthest_link]).data()
			)
			for next_link_data in next_links:
				var next_link := String(
					(next_link_data as GameStateString).data
				)
				if already_searched_provinces.find(next_link) == -1:
					var link_appended: Array = link.duplicate()
					link_appended.append(next_link)
					new_links.append(link_appended)
					already_searched_provinces.append(next_link)
		
		# Find a province further away
		actions = _find_target_province(
			game_state, new_links, province_key, army_key, depth + 1
		)
	return actions


func _new_link_tree(province: GameStateArray) -> Array:
	var links: Array = []
	var province_links: Array[GameStateData] = (
		province.get_array("links").data()
	)
	for province_link_data in province_links:
		var province_link := province_link_data as GameStateString
		links.append([String(province_link.data)])
	return links
