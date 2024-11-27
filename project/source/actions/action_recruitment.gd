class_name ActionRecruitment
extends Action
## Recruits a new [Army] of given size in given [Province].
## You must provide a new unique id for the new army.


const PROVINCE_ID_KEY: String = "province_id"
const NUMBER_OF_TROOPS_KEY: String = "number_of_troops"
const NEW_ARMY_ID_KEY: String = "new_army_id"

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
		push_warning(
				"Tried to recruit troops in a province that doesn't exist!"
		)
		return

	var recruit_limits := ArmyRecruitmentLimits.new(
			your_country, province, game
	)
	if recruit_limits.maximum() < _number_of_troops:
		push_warning(
				"Tried to recruit troops, but not all conditions were met: "
				+ recruit_limits.error_message
		)
		return
	if recruit_limits.minimum() > _number_of_troops:
		push_warning(
				"Tried recruiting an army, but the army's size "
				+ "would be smaller than the minimum allowed."
		)
		return

	your_country.money -= Army.money_cost(_number_of_troops, game.rules)
	province.population.population_size -= (
			Army.population_cost(_number_of_troops, game.rules)
	)

	# If you already have an active army in this province, increase its size.
	for army: Army in (
			game.world.armies_in_each_province.dictionary[province].list
	):
		if army.owner_country == your_country and army.is_able_to_move():
			army.army_size.add(_number_of_troops)
			return

	# Otherwise, create a new army instead.
	var _army: Army = Army.quick_setup(
			game,
			_number_of_troops,
			province.owner_country,
			province,
			_new_army_id
	)


func raw_data() -> Dictionary:
	return {
		ID_KEY: RECRUITMENT,
		PROVINCE_ID_KEY: _province_id,
		NUMBER_OF_TROOPS_KEY: _number_of_troops,
		NEW_ARMY_ID_KEY: _new_army_id,
	}


static func from_raw_data(data: Dictionary) -> ActionRecruitment:
	if not (
			ParseUtils.dictionary_has_number(data, PROVINCE_ID_KEY)
			and ParseUtils.dictionary_has_number(data, NUMBER_OF_TROOPS_KEY)
			and ParseUtils.dictionary_has_number(data, NEW_ARMY_ID_KEY)
	):
		return null

	return ActionRecruitment.new(
			ParseUtils.dictionary_int(data, PROVINCE_ID_KEY),
			ParseUtils.dictionary_int(data, NUMBER_OF_TROOPS_KEY),
			ParseUtils.dictionary_int(data, NEW_ARMY_ID_KEY),
	)
