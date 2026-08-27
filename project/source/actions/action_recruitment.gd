class_name ActionRecruitment
extends Action
## Recruits a new [Army] of given size in given [Province].
## You must provide a new unique id for the new army.

const _PROVINCE_ID_KEY: String = "province_id"
const _NUM_TROOPS_KEY: String = "number_of_troops"
const _NEW_ARMY_ID_KEY: String = "new_army_id"

var _province_id: int
var _number_of_troops: int
var _new_army_id: int


func _init(province_id: int, number_of_troops: int, new_army_id: int) -> void:
	_province_id = province_id
	_number_of_troops = number_of_troops
	_new_army_id = new_army_id


func apply_to(game: Game, player: GamePlayer) -> void:
	var recruitment: ArmyRecruitment = ArmyRecruitment.in_game(game)
	if recruitment == null:
		push_warning("Tried to recruit troops, but recruitment is disabled!")
		return

	var your_country: Country = player.playing_country
	var province: Province = (
			game.world.provinces.map.get(_province_id)
	)

	if province == null:
		push_warning(
				"Tried to recruit troops in a province that doesn't exist!"
		)
		return

	var recruit_limits := ArmyRecruitmentLimits.new(
			game, your_country, province
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

	your_country.money -= recruitment.money_cost(_number_of_troops)
	province.population().value -= (
			recruitment.population_cost(_number_of_troops)
	)

	# If you already have an active army in this province, increase its size.
	for army: Army in (
			game.world.armies_in_each_province
			.dictionary[province.id].ordered_list
	):
		if army.owner_country == your_country and army.is_able_to_move():
			army.size().value += _number_of_troops
			return

	# Otherwise, create a new army instead.
	Army.Factory.new(game).new_army(
			province.owner_country,
			province.id,
			_number_of_troops,
			_new_army_id
	)


func to_raw_dict() -> Dictionary:
	return {
		_ID_KEY: RECRUITMENT,
		_PROVINCE_ID_KEY: _province_id,
		_NUM_TROOPS_KEY: _number_of_troops,
		_NEW_ARMY_ID_KEY: _new_army_id,
	}


static func from_raw_dict(raw_dict: Dictionary) -> ActionRecruitment:
	if not (
			ParseUtils.dictionary_has_number(raw_dict, _PROVINCE_ID_KEY)
			and ParseUtils.dictionary_has_number(raw_dict, _NUM_TROOPS_KEY)
			and ParseUtils.dictionary_has_number(raw_dict, _NEW_ARMY_ID_KEY)
	):
		return null

	return ActionRecruitment.new(
			ParseUtils.dictionary_int(raw_dict, _PROVINCE_ID_KEY),
			ParseUtils.dictionary_int(raw_dict, _NUM_TROOPS_KEY),
			ParseUtils.dictionary_int(raw_dict, _NEW_ARMY_ID_KEY),
	)
