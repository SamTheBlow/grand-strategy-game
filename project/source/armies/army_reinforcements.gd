class_name ArmyReinforcements
## Class responsible for spawning a new [Army]
## in given [Province] according to the [GameRules].
## Merges the armies in given province after creating an army.


func reinforce_province(province: Province) -> void:
	if (
			province == null
			or not province.game.rules.reinforcements_enabled.value
			or province.owner_country == null
	):
		return
	
	var reinforcements_size: int = 0
	match province.game.rules.reinforcements_option.selected:
		GameRules.ReinforcementsOption.RANDOM:
			reinforcements_size = province.game.rng.randi_range(
					province.game.rules.reinforcements_random_min.value,
					province.game.rules.reinforcements_random_max.value
			)
		GameRules.ReinforcementsOption.CONSTANT:
			reinforcements_size = (
					province.game.rules.reinforcements_constant.value
			)
		GameRules.ReinforcementsOption.POPULATION:
			reinforcements_size = floori(
					province.population.population_size
					* province.game.rules.reinforcements_per_person.value
			)
		_:
			push_warning("Unrecognized army reinforcements option.")
	
	if reinforcements_size < province.game.rules.minimum_army_size.value:
		return
	
	Army.quick_setup(
			province.game,
			province.game.world.armies.new_unique_id(),
			reinforcements_size,
			province.owner_country,
			province,
			1
	)
	province.game.world.armies.merge_armies(province)
