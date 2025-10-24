class_name ArmyReinforcements
## Adds troops in given province according to the [GameRules].
## Creates a new [Army] if needed.


static func apply(game: Game, province: Province) -> void:
	if (
			province.owner_country == null
			or not game.rules.reinforcements_enabled.value
	):
		return

	var reinforcements_size: int = 0
	match game.rules.reinforcements_option.selected_value():
		GameRules.ReinforcementsOption.RANDOM:
			reinforcements_size = game.rng.randi_range(
					game.rules.reinforcements_random_min.value,
					game.rules.reinforcements_random_max.value
			)
		GameRules.ReinforcementsOption.CONSTANT:
			reinforcements_size = (
					game.rules.reinforcements_constant.value
			)
		GameRules.ReinforcementsOption.POPULATION:
			reinforcements_size = floori(
					province.population().value
					* game.rules.reinforcements_per_person.value
			)
		_:
			push_warning("Unrecognized army reinforcements option.")

	if reinforcements_size < game.rules.minimum_army_size.value:
		return

	# Creating new armies is bad for performance.
	# It's better to directly increase an existing army's size.
	for army: Army in (
			game.world.armies_in_each_province.in_province(province).list
	):
		if army.owner_country != province.owner_country:
			continue

		army.army_size.add(reinforcements_size)
		return

	# Couldn't find a valid army to reinforce. Create a new army.
	Army.quick_setup(
			game,
			reinforcements_size,
			province.owner_country,
			province.id,
			-1,
			1
	)
