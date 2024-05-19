class_name ActionBuild
extends Action
## Action for building a building in a province.


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
		print_debug(
				"Tried to build a fortress in a province that doesn't exist!"
		)
		return
	
	var build_conditions := FortressBuildConditions.new(your_country, province)
	if not build_conditions.can_build():
		print_debug(
				"Tried to build a fortress, but not all conditions were met: "
				+ build_conditions.error_message
		)
		return
	
	var fortress: Fortress = Fortress.new_fortress(game, province)
	fortress.add_visuals()
	province.buildings.add(fortress)
	
	your_country.money -= game.rules.fortress_price
