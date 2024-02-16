class_name ActionRecruitment
extends Action
## Action for recruiting troops in a province.


var _province_id: int
var _number_of_troops: int
var _new_army_id: int


func _init(province_id: int, number_of_troops: int, new_army_id: int) -> void:
	_province_id = province_id
	_number_of_troops = number_of_troops
	_new_army_id = new_army_id


func apply_to(game: Game, player: Player) -> void:
	var your_country: Country = player.playing_country
	var province: Province = (
			game.world.provinces.province_from_id(_province_id)
	)
	
	if not province:
		print_debug(
				"Tried to recruit troops in a province that doesn't exist!"
		)
		return
	
	var troop_maximum := ArmyRecruitmentLimit.new(your_country, province)
	if troop_maximum.maximum() < _number_of_troops:
		print_debug(
				"Tried to recruit troops, but not all conditions were met: "
				+ troop_maximum.error_message
		)
		return
	
	# TODO it should be OK to recruit less than minimum if there's 
	# already enough troops in that province
	if _number_of_troops < game.rules.minimum_army_size:
		print_debug("Tried recruiting less than the minimum army size.")
		return
	
	your_country.money -= Army.money_cost(_number_of_troops, game.rules)
	province.population.population_size -= (
			Army.population_cost(_number_of_troops, game.rules)
	)
	
	var _army: Army = Army.quick_setup(
			game,
			_new_army_id,
			_number_of_troops,
			province.owner_country(),
			province
	)
	game.world.armies.merge_armies(province)
