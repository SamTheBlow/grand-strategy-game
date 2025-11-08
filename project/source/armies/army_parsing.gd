class_name ArmyParsing
## Parses raw data from/to [Army] instances.

const _MOVEMENTS_KEY: String = "number_of_movements_made"
const _ID_KEY: String = "id"
const _SIZE_KEY: String = "army_size"
const _OWNER_ID_KEY: String = "owner_country_id"
const _PROVINCE_ID_KEY: String = "province_id"


## NOTE: Many things in given game must be loaded before using this.
## Please read the code carefully to know what to load first (sorry!)
##
## Clears already existing armies in given game.
##
## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
## Discards armies with an already-in-use id.
static func load_from_raw_data(raw_data: Variant, game: Game) -> void:
	game.world.armies.reset()

	if raw_data is not Array:
		return
	var raw_array: Array = raw_data

	for army_data: Variant in raw_array:
		_load_army_from_raw_data(army_data, game)


static func to_raw_array(armies_list: Array[Army]) -> Array:
	var output: Array = []

	for army in armies_list:
		var army_data: Dictionary = {
			_ID_KEY: army.id,
			_SIZE_KEY: army.size().value,
			_OWNER_ID_KEY: army.owner_country.id,
			_PROVINCE_ID_KEY: army.province_id(),
		}

		# Movements made (only include this when it's not the default 0)
		if army.movements_made() != 0:
			army_data.merge({ _MOVEMENTS_KEY: army.movements_made() })

		output.append(army_data)

	return output


static func _load_army_from_raw_data(raw_data: Variant, game: Game) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	# Army id (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, _ID_KEY):
		return
	var id: int = ParseUtils.dictionary_int(raw_dict, _ID_KEY)

	# The id must be valid and available.
	if not game.world.armies.id_system().is_id_available(id):
		return

	# Army size (optional, defaults to 1)
	var army_size: int = 1
	if ParseUtils.dictionary_has_number(raw_dict, _SIZE_KEY):
		army_size = ParseUtils.dictionary_int(raw_dict, _SIZE_KEY)

	# Owner country (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, _OWNER_ID_KEY):
		return
	var owner_country_id: int = (
			ParseUtils.dictionary_int(raw_dict, _OWNER_ID_KEY)
	)
	var owner_country: Country = (
			game.countries.country_from_id(owner_country_id)
	)
	if owner_country == null:
		return

	# Province (optional, defaults to no province)
	var province_id: int = -1
	if ParseUtils.dictionary_has_number(raw_dict, _PROVINCE_ID_KEY):
		province_id = ParseUtils.dictionary_int(raw_dict, _PROVINCE_ID_KEY)

	# Movements made (optional, defaults to 0)
	var movements_made: int = 0
	if ParseUtils.dictionary_has_number(raw_dict, _MOVEMENTS_KEY):
		movements_made = ParseUtils.dictionary_int(raw_dict, _MOVEMENTS_KEY)

	Army.quick_setup(
			game,
			army_size,
			owner_country,
			province_id,
			id,
			movements_made
	)
