class_name TestAI1
extends PlayerAI
## Test AI.
## Always tries to move its armies to the nearest non-controlled province.
## Also leaves some troops idle to defend.
## Builds fortresses in the most populated provinces on the frontline.


func play(game: Game) -> void:
	var result: Array[Action] = []
	
	result.append_array(_try_build_fortresses(game))
	
	var provinces: Array[Province] = game.world.provinces.get_provinces()
	var number_of_provinces: int = provinces.size()
	for i in number_of_provinces:
		var province: Province = provinces[i]
		var link_tree: Array = _new_link_tree(province)
		
		# Find the nearest target province for each of your armies
		var armies: Array[Army] = game.world.armies.armies_in_province(province)
		for army in armies:
			if army.owner_country().id == playing_country.id:
				var new_actions: Array[Action] = _find_target_province(
						link_tree,
						province,
						army,
						0
				)
				result.append_array(new_actions)
	
	actions = result


func _try_build_fortresses(game: Game) -> Array[Action]:
	if not game.rules.can_buy_fortress:
		return []
	
	var output: Array[Action] = []
	
	# Try building in each province, starting from the most populated
	var candidates: Array[Province] = (
			game.world.provinces.provinces_on_frontline(playing_country)
	)
	var expected_money: int = playing_country.money
	while (
			candidates.size() > 0
			and expected_money >= game.rules.fortress_price
	):
		# Find the most populated province
		var most_populated: Province
		for province in candidates:
			if not most_populated:
				most_populated = province
				continue
			if (
					province.population.population_size
					> most_populated.population.population_size
			):
				most_populated = province
		
		# Build in that province, if possible
		var build_conditions := FortressBuyConditions.new(playing_country, most_populated)
		if build_conditions.can_buy():
			output.append(ActionBuild.new(most_populated.id))
			expected_money -= game.rules.fortress_price
		
		candidates.erase(most_populated)
	
	return output


# A link tree takes the form of [[p1, p2], [p3, p4], ...]
# where p1, p3 are direct links, p2 and p4 are links of the links, etc.
# In this case, p2 is a link of p1 and p4 is a link of p3.
# (This is a recursive function.)
func _find_target_province(
		link_tree: Array,
		province: Province,
		army: Army,
		depth: int
) -> Array[Action]:
	var new_actions: Array[Action] = []
	
	# Prevent infinite loop if it's impossible to find a target to capture
	if depth >= 100:
		return []
	
	# Get a list of all the provinces you don't own
	var targets: Array = []
	for link_branch: Array in link_tree:
		var furthest_link: int = link_branch.size() - 1
		var link_owner: Country = link_branch[furthest_link].owner_country()
		if link_owner.id != playing_country.id:
			targets.append(link_branch)
	
	# If there's any, send troops evenly to each province
	var number_of_targets: int = targets.size()
	if number_of_targets > 0:
		# Split the troops evenly
		# If there's more targets than available troops, don't split at all
		var troop_count: int = army.army_size.current_size()
		var number_of_armies: int = number_of_targets + 1
		@warning_ignore("integer_division")
		var troops_per_army: int = troop_count / number_of_armies
		
		var new_army_ids: Array[int] = []
		
		if troops_per_army >= army.game.rules.minimum_army_size:
			# Create the partition
			var troop_partition: Array[int] = []
			for i in number_of_armies:
				troop_partition.append(troops_per_army)
			troop_partition[0] += troop_count % number_of_armies
			
			# Get unique ids for the new armies
			new_army_ids = army.game.world.armies.new_unique_army_ids(
					number_of_targets
			)
			
			var action := ActionArmySplit.new(
					army.id,
					troop_partition,
					new_army_ids
			)
			#print("New split action created for army ", army.id, ". The new ids are: ", new_army_ids)
			new_actions.append(action)
		
		# Move your armies towards the targets
		var number_of_armies_to_move: int = new_army_ids.size()
		for i in number_of_armies_to_move:
			var action := ActionArmyMovement.new(
					new_army_ids[i], targets[i][0].id
			)
			#print("New movement action created for army ", new_army_ids[i])
			new_actions.append(action)
	else:
		# Make a new link tree
		var new_link_tree: Array = []
		
		# Make a list of all the provinces we've already searched
		var already_searched_provinces: Array[Province] = [province]
		for link_branch: Array in link_tree:
			for link: Province in link_branch:
				if already_searched_provinces.find(link) == -1:
					already_searched_provinces.append(link)
		
		# Get the linked provinces that have not been searched yet
		for link_branch: Array in link_tree:
			var furthest_link: int = link_branch.size() - 1
			var next_links: Array[Province] = link_branch[furthest_link].links
			for next_link in next_links:
				if already_searched_provinces.find(next_link) == -1:
					var new_branch: Array = link_branch.duplicate()
					new_branch.append(next_link)
					new_link_tree.append(new_branch)
					already_searched_provinces.append(next_link)
		
		# Find a province further away
		new_actions = _find_target_province(
				new_link_tree, province, army, depth + 1
		)
	return new_actions


func _new_link_tree(province: Province) -> Array:
	var link_tree: Array = []
	for link in province.links:
		link_tree.append([link])
	return link_tree
