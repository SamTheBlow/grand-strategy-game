class_name ArmyPlacement
extends GameComponent
## During game setup, adds a new army in every owned province.

const KEY: String = "army_placement"
const TITLE: String = "Army Placement"
const DESCRIPTION: String = "During game setup, adds a new army in every owned province."
const SETTINGS: Array = [
	{ "property_name": _ARMY_SIZE_KEY, "text": "Army size", "type": "int", "min": 0 },
]

const _ARMY_SIZE_KEY: String = "army_size"

var army_size: int = 0


func _init() -> void:
	priority_index = 7


func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	if army_size < game.world.army_data.minimum_size:
		return
	for province in game.world.provinces.list:
		if province.owner_country == null:
			continue
		Army.Factory.new(game).new_army(
				province.owner_country, province.id, army_size
		)


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if army_size >= 0:
		output[_ARMY_SIZE_KEY] = army_size
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _ARMY_SIZE_KEY):
		army_size = maxi(0, ParseUtils.dictionary_int(raw_dict, _ARMY_SIZE_KEY))
	else:
		army_size = 0
