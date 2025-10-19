class_name ArmiesFromRaw
## Converts raw data into [Armies].
## Many things in the game must be loaded before using this.
## Please read the code carefully to know what to load first (sorry!)
##
## This operation always succeeds.
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.
## Discards armies with an already-in-use id.

const ARMY_MOVEMENTS_KEY: String = "number_of_movements_made"
const ARMY_ID_KEY: String = "id"
const ARMY_SIZE_KEY: String = "army_size"
const ARMY_OWNER_ID_KEY: String = "owner_country_id"
const ARMY_PROVINCE_ID_KEY: String = "province_id"


static func parse_using(raw_data: Variant, game: Game) -> void:
	game.world.armies.reset()

	if raw_data is not Array:
		return
	var raw_array: Array = raw_data

	for army_data: Variant in raw_array:
		_parse_army(army_data, game)


static func _parse_army(raw_data: Variant, game: Game) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	# Army id (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, ARMY_ID_KEY):
		return
	var id: int = ParseUtils.dictionary_int(raw_dict, ARMY_ID_KEY)

	# The id must be valid and available.
	if not game.world.armies.id_system().is_id_available(id):
		return

	# Army size (optional, defaults to 1)
	var army_size: int = 1
	if ParseUtils.dictionary_has_number(raw_dict, ARMY_SIZE_KEY):
		army_size = ParseUtils.dictionary_int(raw_dict, ARMY_SIZE_KEY)

	# Owner country (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, ARMY_OWNER_ID_KEY):
		return
	var owner_country_id: int = (
			ParseUtils.dictionary_int(raw_dict, ARMY_OWNER_ID_KEY)
	)
	var owner_country: Country = (
			game.countries.country_from_id(owner_country_id)
	)
	if owner_country == null:
		return

	# Province (optional, defaults to no province)
	var province_id: int = -1
	if not ParseUtils.dictionary_has_number(raw_dict, ARMY_PROVINCE_ID_KEY):
		province_id = ParseUtils.dictionary_int(raw_dict, ARMY_PROVINCE_ID_KEY)

	# Movements made (optional, defaults to 0)
	var movements_made: int = 0
	if ParseUtils.dictionary_has_number(raw_dict, ARMY_MOVEMENTS_KEY):
		movements_made = ParseUtils.dictionary_int(raw_dict, ARMY_MOVEMENTS_KEY)

	Army.quick_setup(
			game,
			army_size,
			owner_country,
			province_id,
			id,
			movements_made
	)
