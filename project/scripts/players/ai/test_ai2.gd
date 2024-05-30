class_name TestAI2
extends PlayerAI
## Test AI.
## Tries to maintain a well-defended frontline.
## Only attacks when it's safe.
## Tries to build fortresses on the frontline where they are needed the most.


func actions(game: Game, player: GamePlayer) -> Array[Action]:
	var result: Array[Action] = []
	
	var provinces: Array[Province] = game.world.provinces.get_provinces()
	var number_of_provinces: int = provinces.size()
	
	# Get a list of all my provinces
	# Get a list of all my frontline provinces
	var my_provinces: Array[Province] = []
	var borders: Array[Province] = []
	for i in number_of_provinces:
		var province: Province = provinces[i]
		if province.owner_country() != player.playing_country:
			continue
		my_provinces.append(province)
		for link in province.links:
			if link.owner_country() != player.playing_country:
				borders.append(province)
				break
	
	# Give a danger level to each border province
	# based on how well defended it is
	var danger_levels: Array[float] = []
	for province in borders:
		var danger_level: float = 0.0
		
		var army_size: int = _army_size(
				game, province, true, player.playing_country
		)
		for link in province.links:
			if link.owner_country() == player.playing_country:
				continue
			var enemy_army_size: int = _army_size(
					game, link, false, player.playing_country
			)
			
			var danger: float = enemy_army_size / (army_size + 0.01)
			# Reduce penalty when there's a fortress
			if link.buildings._buildings.size() > 0:
				danger *= 0.5
			# Amplify penalty in extreme cases
			danger **= 2.0
			
			danger_level += minf(danger, 5.0)
		
		danger_levels.append(danger_level)
	
	result.append_array(_try_build_fortresses(
			game, player.playing_country, borders, danger_levels
	))
	
	# Move armies to the frontline.
	# Move more towards places with bigger danger.
	for province in my_provinces:
		if borders.size() == 0:
			# No frontline! You probably won.
			break
		
		# NOTE assuming there is only one army per province
		var armies: Array[Army] = game.world.armies.armies_in_province(province)
		if armies.size() == 0:
			continue
		var army: Army = armies[0]
		var army_size: int = army.army_size.current_size()
		
		if borders.has(province):
			# Get a list of all the hostile neighbors
			var hostile_neighbors: Array[Province] = []
			for link in province.links:
				if link.owner_country() != province.owner_country():
					hostile_neighbors.append(link)
			
			# If there is only one, then it's safe to full send.
			if hostile_neighbors.size() == 1:
				# NOTE again, assuming there is only one army in a province
				var hostile_armies: Array[Army] = (
						game.world.armies
						.armies_in_province(hostile_neighbors[0])
				)
				
				var do_it: bool = false
				if hostile_armies.size() == 0:
					do_it = true
				else:
					var hostile_army_size: int = (
							hostile_armies[0].army_size.current_size()
					)
					if army_size >= hostile_army_size * 1.69:
						do_it = true
				
				if do_it:
					result.append(ActionArmyMovement.new(
							army.id, hostile_neighbors[0].id
					))
			# Otherwise, we need to keep some troops at home to defend.
			else:
				# The list where we put all the provinces we'll attack
				var attack_list: Array[Province] = []
				
				# Get all the hostile armies
				# If there's no army in a province, add it to the attack list
				var hostile_armies: Array[Army] = []
				for hostile_neighbor in hostile_neighbors:
					var armies_in_province: Array[Army] = (
							game.world.armies
							.armies_in_province(hostile_neighbor)
					)
					if armies_in_province.size() == 0:
						attack_list.append(hostile_neighbor)
					else:
						hostile_armies.append(armies_in_province[0])
				
				# Compare the hostile armies with your army
				var size_sum: int = 0
				for hostile_army in hostile_armies:
					var size: int = hostile_army.army_size.current_size()
					# If any of them is too big, don't attack
					if army_size < size:
						attack_list.clear()
						break
					# If any of them is too small, attack them
					if army_size >= size * (1.75 + randf() * 0.5):
						attack_list.append(hostile_army.province())
					size_sum += size
				# If the sum of their sizes is too big, don't attack
				if army_size * (1.75 + randf() * 0.5) < size_sum:
					attack_list.clear()
				
				if attack_list.size() > 0:
					# If we're attacking all neighbors, then full send
					var full_send: bool = false
					if attack_list.size() == hostile_neighbors.size():
						full_send = true
					
					# Split up the army
					var new_army_count: int = attack_list.size()
					if full_send:
						new_army_count -= 1
					var new_army_ids2: Array[int] = (
							army.game.world.armies
							.new_unique_army_ids(new_army_count)
					)
					var partition2: Array[int] = []
					var part_sum: int = 0
					var parts: int = new_army_count + 1
					for i in parts:
						var part: int = floori(army_size / float(parts))
						partition2.append(part)
						part_sum += part
					partition2[0] += army_size - part_sum
					
					# If any of the parts is too small, then you can't split
					var is_large_enough: bool = true
					for part in partition2:
						if part < game.rules.minimum_army_size:
							is_large_enough = false
							break
					
					if is_large_enough:
						result.append(ActionArmySplit.new(
								army.id, partition2, new_army_ids2
						))
						
						# Move the new armies
						for i in attack_list.size():
							if full_send and i == attack_list.size() - 1:
								result.append(ActionArmyMovement.new(
										army.id, attack_list[i].id
								))
								continue
							result.append(ActionArmyMovement.new(
									new_army_ids2[i], attack_list[i].id
							))
			
			continue
		# This province is not on the frontline
		
		# Move the army towards the frontlines
		var nearest_frontlines: Array = _nearest_frontlines(
				_new_link_tree(province), province, 0
		)
		if nearest_frontlines.size() > 0:
			# Take the most endangered province as the target to reach
			var target_province: Province
			var target_danger: float = 0.0
			for link_tree: Array in nearest_frontlines:
				var border: Province = link_tree[link_tree.size() - 1]
				var i: int = borders.find(border)
				if danger_levels[i] >= target_danger:
					target_province = link_tree[0]
					target_danger = danger_levels[i]
			
			result.append(ActionArmyMovement.new(
					army.id, target_province.id
			))
	
	return result


func _army_size(
		game: Game,
		province: Province,
		is_yours: bool,
		playing_country: Country
) -> int:
	var output: int = 0
	var armies: Array[Army] = game.world.armies.armies_in_province(province)
	for army in armies:
		if is_yours:
			if army.owner_country == playing_country:
				output += army.army_size.current_size()
		else:
			if army.owner_country != playing_country:
				output += army.army_size.current_size()
	return output


# TODO DRY. This is mostly a copy/paste from the other AI...
func _try_build_fortresses(
		game: Game,
		playing_country: Country,
		borders: Array[Province],
		danger_levels: Array[float]
) -> Array[Action]:
	if not game.rules.build_fortress_enabled:
		return []
	
	var output: Array[Action] = []
	
	# Try building in each province, starting from the most populated
	var candidates: Array[Province] = borders.duplicate()
	var expected_money: int = playing_country.money
	while (
			candidates.size() > 0
			and expected_money >= game.rules.fortress_price
	):
		# Find the most endangered province
		var most_endangered_index: int = -1
		for i in candidates.size():
			if (
					most_endangered_index == -1
					or danger_levels[i] > danger_levels[most_endangered_index]
			):
				most_endangered_index = i
		var most_endangered_province: Province = (
				candidates[most_endangered_index]
		)
		
		# Build in that province, if possible
		var build_conditions := FortressBuildConditions.new(
				playing_country, most_endangered_province
		)
		if build_conditions.can_build():
			output.append(ActionBuild.new(most_endangered_province.id))
			expected_money -= game.rules.fortress_price
		
		candidates.remove_at(most_endangered_index)
	
	return output


# A link tree takes the form of [[p1, p2], [p3, p4], ...]
# where p1, p3 are direct links, p2 and p4 are links of the links, etc.
# In this case, p2 is a link of p1 and p4 is a link of p3.
# (This is a recursive function.)
func _nearest_frontlines(
		link_tree: Array,
		source_province: Province,
		depth: int
) -> Array:
	# Prevent infinite loop
	if depth >= 100:
		return []
	
	# Get a list of all the frontlines we've found
	var frontline_branches: Array = []
	for link_branch: Array in link_tree:
		var furthest_province: Province = link_branch[link_branch.size() - 1]
		for link in furthest_province.links:
			if link.owner_country() != source_province.owner_country():
				frontline_branches.append(link_branch)
				break
	# If we found any, then we're done
	if frontline_branches.size() > 0:
		return frontline_branches
	
	# Make a new link tree
	var new_link_tree: Array = []
	
	# Make a list of all the provinces we've already searched
	var already_searched_provinces: Array[Province] = [source_province]
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
	
	# Look further away for the frontline
	return _nearest_frontlines(new_link_tree, source_province, depth + 1)


func _new_link_tree(province: Province) -> Array:
	var link_tree: Array = []
	for link in province.links:
		link_tree.append([link])
	return link_tree
