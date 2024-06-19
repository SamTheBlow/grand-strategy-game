class_name TestAI1
extends PlayerAI
## Test AI.
## Always tries to move its armies to the nearest non-controlled province.
## Also leaves some troops idle to defend.
## Builds fortresses in the most populated provinces on the frontline.


func actions(game: Game, player: GamePlayer) -> Array[Action]:
	var result: Array[Action] = []
	
	result.append_array(_try_build_fortresses(game, player.playing_country))
	
	var provinces: Array[Province] = game.world.provinces.list()
	var number_of_provinces: int = provinces.size()
	for i in number_of_provinces:
		var province: Province = provinces[i]
		var link_tree: Array = _new_link_tree(province)
		
		# Find the nearest target province for each of your armies
		var armies: Array[Army] = game.world.armies.armies_in_province(province)
		for army in armies:
			if army.owner_country.id == player.playing_country.id:
				var new_actions: Array[Action] = _find_target_province(
						link_tree,
						province,
						army,
						0
				)
				result.append_array(new_actions)
	
	return result


func _try_build_fortresses(
		game: Game,
		playing_country: Country
) -> Array[Action]:
	if not game.rules.build_fortress_enabled.value:
		return []
	
	var output: Array[Action] = []
	
	# Try building in each province, starting from the most populated
	var candidates: Array[Province] = (
			game.world.provinces.provinces_on_frontline(playing_country)
	)
	var expected_money: int = playing_country.money
	while (
			candidates.size() > 0
			and expected_money >= game.rules.fortress_price.value
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
		var build_conditions := FortressBuildConditions.new(
				playing_country, most_populated
		)
		if build_conditions.can_build():
			output.append(ActionBuild.new(most_populated.id))
			expected_money -= game.rules.fortress_price.value
		
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
		depth: int,
) -> Array[Action]:
	var new_actions: Array[Action] = []
	
	# Prevent infinite loop if it's impossible to find a target to capture
	if depth >= 100:
		return []
	
	# Get a list of all the provinces you don't own
	var targets: Array = []
	for link_branch: Array in link_tree:
		var furthest_link: int = link_branch.size() - 1
		var link_owner: Country = link_branch[furthest_link].owner_country
		if (not link_owner) or (link_owner.id != army.owner_country.id):
			targets.append(link_branch)
	
	# If there's any, send troops evenly to each province
	var number_of_targets: int = targets.size()
	if number_of_targets > 0:
		# Build array of destination provinces
		var destination_provinces: Array[Province] = []
		destination_provinces.append(army.province())
		for i in number_of_targets:
			destination_provinces.append(targets[i][0])
		
		var army_even_split := ArmyEvenSplit.new()
		army_even_split.apply(army, destination_provinces)
		
		if army_even_split.action_army_split != null:
			new_actions.append(army_even_split.action_army_split)
		for i in army_even_split.action_army_movements.size():
			if i == 0:
				continue
			new_actions.append(army_even_split.action_army_movements[i])
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
