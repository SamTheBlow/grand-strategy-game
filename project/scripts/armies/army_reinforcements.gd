class_name ArmyReinforcements
## Class responsible for spawning new armies in given [Province].
## Creates a new [Army] under the control of the province's owner [Country].
## The army's size depends on the [GameRules].
## Then, armies in given province are merged together.
##
## This class is meant to be used when a new turn begins (see [GameTurn]).


func reinforce_province(province: Province) -> void:
	if not province.game.rules.reinforcements_enabled:
		return
	
	if not province.has_owner_country():
		return
	
	var reinforcements_size: int = 0
	match province.game.rules.reinforcements_option:
		GameRules.ReinforcementsOption.RANDOM:
			reinforcements_size = randi_range(
					province.game.rules.reinforcements_random_min,
					province.game.rules.reinforcements_random_max
			)
		GameRules.ReinforcementsOption.CONSTANT:
			reinforcements_size = province.game.rules.reinforcements_constant
		GameRules.ReinforcementsOption.POPULATION:
			reinforcements_size = floori(
					province.population.population_size
					* province.game.rules.reinforcements_per_person
			)
	
	var _army: Army = Army.quick_setup(
			province.game,
			province.game.world.armies.new_unique_army_id(),
			reinforcements_size,
			province.owner_country(),
			province
	)
	province.game.world.armies.merge_armies(province)
