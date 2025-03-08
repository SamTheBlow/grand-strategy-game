class_name TestAI1
extends PlayerAI
## Test AI.
## Moves its armies towards neutral and enemy territory.
## Always attacks. Also leaves some troops idle to defend.
## Builds fortresses in the most populated provinces on the frontline.


func actions(game: Game, player: GamePlayer) -> Array[Action]:
	var result: Array[Action] = super(game, player)

	result.append_array(_try_build_fortresses(game, player.playing_country))

	var armies_of_player: Array[Army] = (
			game.world.armies_of_each_country
			.dictionary[player.playing_country].list
	)
	if armies_of_player.size() >= 50:
		result.append_array(_actions_many(game, player))
	else:
		result.append_array(_actions_few(game, player))

	return result


## Faster when you have few armies.
func _actions_few(game: Game, player: GamePlayer) -> Array[Action]:
	var result: Array[Action] = []

	for province in game.world.provinces.list():
		var destination_provinces: Array[Province] = (
				_destination_provinces(province, player.playing_country)
		)
		var armies_in_province: Array[Army] = (
				game.world.armies_in_each_province.dictionary[province].list
		)
		for army in armies_in_province:
			if army.owner_country != player.playing_country:
				continue

			result.append_array(_new_movement_actions(
					army, destination_provinces, game.world.armies
			))

	return result


## Faster when you have lots of armies.
func _actions_many(game: Game, player: GamePlayer) -> Array[Action]:
	var result: Array[Action] = []

	# Create list of destinations for the pathfinding
	var destinations: Array[Province] = []
	for province in game.world.provinces.list():
		if (
				province.owner_country == null
				or not player.playing_country
				.has_permission_to_move_into_country(
						province.owner_country
				)
		):
			destinations.append(province)

	# Do the pathfinding
	var province_pathfinding := ProvincePathfinding.new(game.world.provinces)
	province_pathfinding.generate(destinations)

	# Create actions for each army
	for my_army: Army in (
			game.world.armies_of_each_country
			.dictionary[player.playing_country].list
	):
		var my_province: Province = my_army.province()
		var provinces_to_move_to: Array[Province] = [my_province]
		for link_branch: LinkBranch in (
				province_pathfinding.paths[my_province].list
		):
			provinces_to_move_to.append(link_branch.furthest_link())

		result.append_array(_new_movement_actions(
				my_army, provinces_to_move_to, game.world.armies
		))

	return result


func _try_build_fortresses(
		game: Game, playing_country: Country
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
		var most_populated: Province = null
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
				playing_country, most_populated, game
		)
		if build_conditions.can_build():
			output.append(ActionBuild.new(most_populated.id))
			expected_money -= game.rules.fortress_price.value

		candidates.erase(most_populated)

	return output


func _new_movement_actions(
		army: Army, destination_provinces: Array[Province], armies: Armies
) -> Array[Action]:
	var new_actions: Array[Action] = []

	var army_even_split := ArmyEvenSplit.new(armies)
	army_even_split.apply(army, destination_provinces)

	if army_even_split.action_army_split != null:
		new_actions.append(army_even_split.action_army_split)
	for i in army_even_split.action_army_movements.size():
		if i == 0:
			continue
		new_actions.append(army_even_split.action_army_movements[i])

	return new_actions


func _destination_provinces(
		source_province: Province, playing_country: Country
) -> Array[Province]:
	var province_filter: Callable = (
			func(province: Province) -> bool:
				return (
						province.owner_country == null
						or not playing_country
						.has_permission_to_move_into_country(
								province.owner_country
						)
				)
	)

	var destination_provinces: Array[Province] = [source_province]
	var calculation := NearestProvinces.new()
	calculation.calculate(source_province, province_filter)
	destination_provinces.append_array(calculation.first_links)
	return destination_provinces
