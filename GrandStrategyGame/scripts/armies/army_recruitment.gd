class_name ArmyRecruitment
## Class responsible for recruiting new armies in given province.


func recruit_in_province(province: Province) -> void:
	if not province.has_owner_country():
		return
	
	var army: Army = Army.quick_setup(
			province.game,
			province.armies.new_unique_army_id(),
			province.population.population_size,
			province.owner_country(),
			preload("res://scenes/army.tscn")
	)
	army.move_to_province(province)
	province.armies.merge_armies()
