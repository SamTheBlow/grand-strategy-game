class_name ArmyReinforcements
## Class responsible for spawning new armies in given [Province].
## Creates a new [Army] under the control of the province's owner [Country].
## The army's size depends on the [GameRules].
## Then, armies in given province are merged together.
##
## This class is meant to be used when a new turn begins (see [GameTurn]).


func reinforce_province(province: Province) -> void:
	if not province.game.rules.reinforcements_enabled.value:
		return
	
	if not province.owner_country:
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
	
	if reinforcements_size < province.game.rules.minimum_army_size.value:
		return
	
	var _army: Army = Army.quick_setup(
			province.game,
			province.game.world.armies.new_unique_id(),
			reinforcements_size,
			province.owner_country,
			province,
			1
	)
	province.game.world.armies.merge_armies(province)
