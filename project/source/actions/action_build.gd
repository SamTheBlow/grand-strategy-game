class_name ActionBuild
extends Action
## Builds a [Building] of given type in given [Province].


const PROVINCE_ID_KEY: String = "province_id"
const BUILDING_TYPE_KEY: String = "building_type"

var _province_id: int
var _building_type: int


func _init(
		province_id: int,
		building_type: Building.Type = Building.Type.FORTRESS
) -> void:
	_province_id = province_id
	_building_type = building_type


func apply_to(game: Game, player: GamePlayer) -> void:
	var your_country: Country = player.playing_country
	var province: Province = (
			game.world.provinces.province_from_id(_province_id)
	)
	
	if not province:
		push_warning(
				"Tried to build a fortress in a province that doesn't exist!"
		)
		return
	
	var build_conditions := FortressBuildConditions.new(your_country, province)
	if not build_conditions.can_build():
		push_warning(
				"Tried to build a fortress, but not all conditions were met: "
				+ build_conditions.error_message
		)
		return
	
	province.buildings.add(Fortress.new_fortress(game, province))
	
	your_country.money -= game.rules.fortress_price.value


## Returns this action's raw data, for the purpose of
## transfering between network clients.
func raw_data() -> Dictionary:
	return {
		ID_KEY: BUILD,
		PROVINCE_ID_KEY: _province_id,
		BUILDING_TYPE_KEY: _building_type,
	}


## Returns an action built with given raw data.
static func from_raw_data(data: Dictionary) -> ActionBuild:
	if not (
			ParseUtils.dictionary_has_number(data, PROVINCE_ID_KEY)
			and ParseUtils.dictionary_has_number(data, BUILDING_TYPE_KEY)
	):
		return null
	
	return ActionBuild.new(
			ParseUtils.dictionary_int(data, PROVINCE_ID_KEY),
			ParseUtils.dictionary_int(data, BUILDING_TYPE_KEY),
	)
