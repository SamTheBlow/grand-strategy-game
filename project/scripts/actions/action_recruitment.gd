class_name ActionRecruitment
extends Action
## Recruits a new [Army] of given size in given [Province].
## You must provide a new unique id for the new army.


var _province_id: int
var _number_of_troops: int
var _new_army_id: int


func _init(province_id: int, number_of_troops: int, new_army_id: int) -> void:
	_province_id = province_id
	_number_of_troops = number_of_troops
	_new_army_id = new_army_id


func apply_to(game: Game, player: GamePlayer) -> void:
	var your_country: Country = player.playing_country
	var province: Province = (
			game.world.provinces.province_from_id(_province_id)
	)
	
	if not province:
		print_debug(
				"Tried to recruit troops in a province that doesn't exist!"
		)
		return
	
	var recruit_limits := ArmyRecruitmentLimits.new(your_country, province)
	if recruit_limits.maximum() < _number_of_troops:
		print_debug(
				"Tried to recruit troops, but not all conditions were met: "
				+ recruit_limits.error_message
		)
		return
	if recruit_limits.minimum() > _number_of_troops:
		print_debug(
				"Tried recruiting an army, but the army's size "
				+ "would be smaller than the minimum allowed."
		)
		return
	
	your_country.money -= Army.money_cost(_number_of_troops, game.rules)
	province.population.population_size -= (
			Army.population_cost(_number_of_troops, game.rules)
	)
	
	# If you already have an active army in this province, increase its size.
	for army in game.world.armies.armies_in_province(province):
		if army.owner_country == your_country and army.is_able_to_move():
			army.army_size.add(_number_of_troops)
			return
	
	# Otherwise, create a new army instead.
	var _army: Army = Army.quick_setup(
			game,
			_new_army_id,
			_number_of_troops,
			province.owner_country,
			province
	)


## Returns this action's raw data, for the purpose of
## transfering between network clients.
func raw_data() -> Dictionary:
	return {
		"id": RECRUITMENT,
		"province_id": _province_id,
		"number_of_troops": _number_of_troops,
		"new_army_id": _new_army_id,
	}


# TODO verify that the data is valid
# same problem in [ActionArmyMovement], [ActionArmySplit], [ActionBuild]
## Returns an action built with given raw data.
static func from_raw_data(data: Dictionary) -> ActionRecruitment:
	return ActionRecruitment.new(
			data["province_id"] as int,
			data["number_of_troops"] as int,
			data["new_army_id"] as int,
	)
