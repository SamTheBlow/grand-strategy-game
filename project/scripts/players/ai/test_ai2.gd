class_name TestAI2
extends PlayerAI
## Test AI.
## Tries to maintain a well-defended frontline.
## Only attacks when it's safe.
## Tries to build fortresses on the frontline where they are needed the most.


func actions(game: Game, player: GamePlayer) -> Array[Action]:
	var result: Array[Action] = super(game, player)
	
	var provinces: Array[Province] = game.world.provinces.list()
	var number_of_provinces: int = provinces.size()
	
	# Get a list of all my provinces
	# Get a list of all my frontline provinces
	var my_provinces: Array[Province] = []
	var borders: Array[Province] = []
	for i in number_of_provinces:
		var province: Province = provinces[i]
		if province.owner_country != player.playing_country:
			continue
		my_provinces.append(province)
		for link in province.links:
			if link.owner_country != player.playing_country:
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
			if link.owner_country == player.playing_country:
				continue
			var enemy_army_size: int = _army_size(
					game, link, false, player.playing_country
			)
			
			var danger: float = enemy_army_size / (army_size + 0.01)
			# Reduce penalty when there's a fortress
			if link.buildings.list().size() > 0:
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
		
		var armies: Array[Army] = game.world.armies.active_armies(
				player.playing_country, province
		)
		if armies.size() == 0:
			continue
		# NOTE this assumes that you only have one army in each province
		var army: Army = armies[0]
		var army_size: int = army.army_size.current_size()
		
		if borders.has(province):
			# Get a list of all the hostile link provinces
			var hostile_links: Array[Province] = []
			for link in province.links:
				if (
						link.owner_country != player.playing_country
						and
						province.owner_country.relationships
						.with_country(link.owner_country).is_trespassing()
				):
					hostile_links.append(link)
			
			# If there is only one, then it's safe to full send.
			if hostile_links.size() == 1:
				# Take the sum of all the hostile army sizes
				var hostile_army_size: int = _hostile_army_size(
						army.owner_country, hostile_links[0]
				)
				
				# If your army is relatively large enough, attack!
				if army_size >= hostile_army_size * 1.69:
					result.append(ActionArmyMovement.new(
							army.id, hostile_links[0].id
					))
			# Otherwise, we might need to keep some troops at home to defend.
			else:
				# The list where we put all the provinces we'll attack
				var attack_list: Array[Province] = []
				
				# Compare a province's hostile armies with your army
				var total_hostile_army_size: int = 0
				for hostile_link in hostile_links:
					# Take the sum of all the hostile army sizes
					var hostile_army_size: int = _hostile_army_size(
							army.owner_country, hostile_link
					)
					
					# If the province's army
					# is larger than yours, don't attack at all
					if army_size < hostile_army_size:
						attack_list.clear()
						break
					
					# If the province's army is small enough, attack it
					if army_size >= hostile_army_size * (1.75 + randf() * 0.5):
						attack_list.append(hostile_link)
					
					total_hostile_army_size += hostile_army_size
				
				# If the total size of all the hostile armies
				# is too big, don't attack at all
				if (
						army_size * (1.75 + randf() * 0.5)
						< total_hostile_army_size
				):
					attack_list.clear()
				
				if attack_list.size() > 0:
					# If we're attacking all neighbors, then full send
					var full_send: bool = false
					if attack_list.size() == hostile_links.size():
						full_send = true
					
					# Split up the army
					var new_army_count: int = attack_list.size()
					if full_send:
						new_army_count -= 1
					
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
						if part < game.rules.minimum_army_size.value:
							is_large_enough = false
							break
					
					if is_large_enough:
						var new_army_ids: Array[int] = (
								game.world.armies
								.new_unique_ids(new_army_count)
						)
						result.append(ActionArmySplit.new(
								army.id, partition2, new_army_ids
						))
						
						# Move the new armies
						for i in attack_list.size():
							if full_send and i == attack_list.size() - 1:
								result.append(ActionArmyMovement.new(
										army.id, attack_list[i].id
								))
								continue
							result.append(ActionArmyMovement.new(
									new_army_ids[i], attack_list[i].id
							))
			
			continue
		# This province is not on the frontline
		
		# Move the army towards the frontlines
		var province_filter: Callable = (
				func(province_: Province) -> bool:
					return province_.is_frontline()
		)
		var frontline_calculation := NearestProvinces.new()
		frontline_calculation.calculate(province, province_filter)
		if frontline_calculation.size > 0:
			# Take the most endangered province as the target to reach
			var target_province: Province
			var target_danger: float = 0.0
			for i in frontline_calculation.size:
				var border_index: int = (
						borders.find(frontline_calculation.furthest_links[i])
				)
				if danger_levels[border_index] >= target_danger:
					target_province = frontline_calculation.first_links[i]
					target_danger = danger_levels[border_index]
			
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


## Returns the total army size of all of the hostile armies in given province.
func _hostile_army_size(your_country: Country, province: Province) -> int:
	var hostile_army_size: int = 0
	
	var link_armies: Array[Army] = (
			province.game.world.armies.armies_in_province(province)
	)
	for link_army in link_armies:
		if not Country.is_fighting(your_country, link_army.owner_country):
			continue
		
		hostile_army_size += link_army.army_size.current_size()
	
	return hostile_army_size


# TODO DRY. This is mostly a copy/paste from the other AI...
func _try_build_fortresses(
		game: Game,
		playing_country: Country,
		borders: Array[Province],
		danger_levels: Array[float]
) -> Array[Action]:
	if not game.rules.build_fortress_enabled.value:
		return []
	
	var output: Array[Action] = []
	
	# Try building in each province, starting from the most populated
	var candidates: Array[Province] = borders.duplicate()
	var expected_money: int = playing_country.money
	while (
			candidates.size() > 0
			and expected_money >= game.rules.fortress_price.value
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
			expected_money -= game.rules.fortress_price.value
		
		candidates.remove_at(most_endangered_index)
	
	return output
