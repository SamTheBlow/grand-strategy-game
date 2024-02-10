class_name ArmyRecruitment
## Class responsible for recruiting new armies in given province.


func recruit_in_province(province: Province) -> void:
	if not province.has_owner_country():
		return
	
	var _army: Army = Army.quick_setup(
			province.game,
			province.game.world.armies.new_unique_army_id(),
			province.population.population_size,
			province.owner_country(),
			province
	)
	province.game.world.armies.merge_armies(province)
