class_name ActionBuild
extends Action
## Builds a fortress in given [Province].

const PROVINCE_ID_KEY: String = "province_id"

var _province_id: int


func _init(province_id: int) -> void:
	_province_id = province_id


func apply_to(game: Game, player: GamePlayer) -> void:
	var your_country: Country = player.playing_country
	var province: Province = (
			game.world.provinces.province_from_id(_province_id)
	)

	if province == null:
		push_warning("Province is null.")
		return

	var build_conditions := (
			FortressBuildConditions.new(your_country, province, game)
	)
	if not build_conditions.can_build():
		push_warning(
				"Tried to build a fortress, but not all conditions were met: "
				+ build_conditions.error_message
		)
		return

	var building := Building.new(game.world.fortress_data(), _province_id)

	# Pay costs
	province.population().value -= building.data.population_cost
	your_country.money -= building.data.money_cost

	province.buildings.add(building)


## Returns this action's raw data, for the purpose of
## transfering between network clients.
func raw_data() -> Dictionary:
	return {
		ID_KEY: BUILD,
		PROVINCE_ID_KEY: _province_id,
	}


## Returns an action built with given raw data.
static func from_raw_data(data: Dictionary) -> ActionBuild:
	if not ParseUtils.dictionary_has_number(data, PROVINCE_ID_KEY):
		return null

	return ActionBuild.new(ParseUtils.dictionary_int(data, PROVINCE_ID_KEY))
