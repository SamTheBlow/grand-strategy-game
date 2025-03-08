class_name TestAI2
extends PlayerAI
## Test AI.
## Tries to maintain a well-defended frontline.
## Only attacks when it's safe.
## Tries to build fortresses on the frontline where they are needed the most.


func actions(game: Game, player: GamePlayer) -> Array[Action]:
	var result: Array[Action] = super(game, player)

	var provinces: Array[Province] = game.world.provinces.list()
	var armies_in_province: Dictionary[Province, ArmiesInProvince] = (
			game.world.armies_in_each_province.dictionary
	)
	var frontline_provinces: Array[Province] = (
			game.world.provinces.provinces_on_frontline(player.playing_country)
	)
	var my_armies: Array[Army] = (
			game.world.armies_of_each_country
			.dictionary[player.playing_country].list
	)

	if frontline_provinces.size() == 0:
		# No frontline! You probably won.
		return []

	# Generate pathfinding data, but only when it's worth it.
	var pathfinding: ProvincePathfinding
	if _is_province_pathfinding_worth_it(my_armies):
		pathfinding = ProvincePathfinding.new(game.world.provinces)
		pathfinding.generate(frontline_provinces)

	# Give a danger level to each frontline province
	# based on how well defended it is.
	#
	# Each frontline province is guaranteed to be in this dictionary.
	var danger_levels: Dictionary[Province, float] = {}
	for province in frontline_provinces:
		var danger_level: float = 0.0

		var army_size: int = _army_size(
				armies_in_province[province], true, player.playing_country
		)
		for link in province.links:
			if link.owner_country == player.playing_country:
				continue
			var enemy_army_size: int = _army_size(
					armies_in_province[link], false, player.playing_country
			)

			var danger: float = enemy_army_size / (army_size + 0.01)
			# Reduce penalty when there's a fortress
			if link.buildings.list().size() > 0:
				danger *= 0.5
			# Amplify penalty in extreme cases
			danger **= 2.0

			danger_level += minf(danger, 5.0)

		# Give priority to the war frontline
		if province.is_war_frontline(player.playing_country):
			danger_level *= 3.0

		danger_levels[province] = danger_level

	result.append_array(_try_build_fortresses(
			game, player.playing_country, frontline_provinces, danger_levels
	))

	# Move armies to the frontline.
	# Move more towards places with bigger danger.
	for army in my_armies:
		if army.is_able_to_move() == false:
			continue

		var province: Province = army.province()

		# Is this army on the frontline?
		if frontline_provinces.has(province):
			var army_size: int = army.army_size.current_size()

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
						army.owner_country,
						armies_in_province[hostile_links[0]].list
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
							army.owner_country,
							armies_in_province[hostile_link].list
					)

					# If the province's army
					# is larger than yours, don't attack at all
					if army_size < hostile_army_size:
						attack_list.clear()
						break

					# If the province's army is small enough, attack it
					if (
							hostile_army_size
							* (1.75 + game.rng.randf() * 0.5)
							<= army_size
					):
						attack_list.append(hostile_link)

					total_hostile_army_size += hostile_army_size

				# If the total size of all the hostile armies
				# is too big, don't attack at all
				if (
						army_size * (1.75 + game.rng.randf() * 0.5)
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
								game.world.armies.id_system()
								.new_unique_ids(new_army_count, false)
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
		# This province is not on the frontline.

		# Move the army towards the frontlines.
		if _is_province_pathfinding_worth_it(my_armies):
			_move_towards_frontlines_pathfinding(
					result, army, danger_levels, pathfinding
			)
		else:
			_move_towards_frontlines(
					result, army, danger_levels, player.playing_country
			)

	return result


func _is_province_pathfinding_worth_it(my_armies: Array[Army]) -> bool:
	return my_armies.size() >= 50


## Faster when you have few armies and the frontline is nearby.
func _move_towards_frontlines(
		result: Array[Action],
		army: Army,
		danger_levels: Dictionary[Province, float],
		playing_country: Country
) -> void:
	var province_filter: Callable = (
			func(province: Province) -> bool:
				return province.is_frontline(playing_country)
	)
	var frontline_calculation := NearestProvinces.new()
	frontline_calculation.calculate(army.province(), province_filter)

	if frontline_calculation.size == 0:
		return

	# Take the most endangered province as the target to reach.
	var target_province: Province
	var target_danger: float = 0.0
	for i in frontline_calculation.size:
		var frontline_province: Province = (
				frontline_calculation.furthest_links[i]
		)
		if danger_levels[frontline_province] >= target_danger:
			target_province = frontline_calculation.first_links[i]
			target_danger = danger_levels[frontline_province]

	result.append(ActionArmyMovement.new(army.id, target_province.id))


## Faster when you have many armies and the frontline is far away.
func _move_towards_frontlines_pathfinding(
		result: Array[Action],
		army: Army,
		danger_levels: Dictionary[Province, float],
		pathfinding: ProvincePathfinding
) -> void:
	var link_branches: Array[LinkBranch] = (
			pathfinding.paths[army.province()].list
	)

	if link_branches.size() == 0:
		return

	# Take the most endangered province as the target to reach.
	var target_province: Province
	var target_danger: float = 0.0
	for link_branch in link_branches:
		var frontline_province: Province = link_branch.first_link()
		if danger_levels[frontline_province] >= target_danger:
			target_province = link_branch.furthest_link()
			target_danger = danger_levels[frontline_province]

	result.append(ActionArmyMovement.new(army.id, target_province.id))


func _army_size(
		armies_in_province: ArmiesInProvince,
		is_yours: bool,
		playing_country: Country
) -> int:
	var output: int = 0

	for army in armies_in_province.list:
		if is_yours:
			if army.owner_country == playing_country:
				output += army.army_size.current_size()
		else:
			if army.owner_country != playing_country:
				output += army.army_size.current_size()

	return output


## Returns the total army size of all of the hostile armies in given army list.
func _hostile_army_size(your_country: Country, army_list: Array[Army]) -> int:
	var hostile_army_size: int = 0

	for army in army_list:
		if Country.is_fighting(your_country, army.owner_country):
			hostile_army_size += army.army_size.current_size()

	return hostile_army_size


# TODO DRY. This is mostly a copy/paste from the other AI...
func _try_build_fortresses(
		game: Game,
		playing_country: Country,
		frontline_provinces: Array[Province],
		danger_levels: Dictionary[Province, float]
) -> Array[Action]:
	if not game.rules.build_fortress_enabled.value:
		return []

	var output: Array[Action] = []

	var candidates: Array[Province] = frontline_provinces.duplicate()
	var expected_money: int = playing_country.money

	# Sort the provinces from most to least endangered
	candidates.sort_custom(
			func(element1: Province, element2: Province) -> bool:
				return danger_levels[element1] < danger_levels[element2]
	)

	# Try building in each province, starting from the most endangered
	var i: int = 0
	while (
			i < candidates.size()
			and expected_money >= game.rules.fortress_price.value
	):
		# Build in that province, if possible
		var build_conditions := FortressBuildConditions.new(
				playing_country, candidates[i], game
		)
		if build_conditions.can_build():
			output.append(ActionBuild.new(candidates[i].id))
			expected_money -= game.rules.fortress_price.value

		i += 1

	return output
