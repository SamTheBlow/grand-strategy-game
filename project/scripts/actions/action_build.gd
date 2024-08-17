class_name ActionBuild
extends Action
## Builds a [Building] of given type in given [Province].


var _province_id: int
var _building_type: String


func _init(province_id: int, building_type: String = "fortress") -> void:
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
	
	var fortress: Fortress = Fortress.new_fortress(game, province)
	fortress.add_visuals()
	province.buildings.add(fortress)
	
	your_country.money -= game.rules.fortress_price.value


## Returns this action's raw data, for the purpose of
## transfering between network clients.
func raw_data() -> Dictionary:
	return {
		"id": BUILD,
		"province_id": _province_id,
		"building_type": _building_type,
	}


## Returns an action built with given raw data.
static func from_raw_data(data: Dictionary) -> ActionBuild:
	return ActionBuild.new(
			data["province_id"] as int,
			data["building_type"] as String
	)
