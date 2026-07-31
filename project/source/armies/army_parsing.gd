class_name ArmyParsing
## Parses raw data from/to [Army] instances.

const _ID_KEY: String = "id"
const _TEXTURE_KEY: String = "texture"
const _OWNER_ID_KEY: String = "owner_country_id"
const _SIZE_KEY: String = "army_size"
const _PROVINCE_ID_KEY: String = "province_id"
const _MOVEMENTS_KEY: String = "number_of_movements_made"


## NOTE: Many things in given game must be loaded before using this.
## Please read the code carefully to know what to load first (sorry!)
##
## Clears already existing armies in given game.
##
## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
## Discards armies with an already-in-use id.
static func load_from_raw_data(
		raw_data: Variant, game: Game, project_textures: ProjectTextures
) -> void:
	game.world.armies.reset()

	if raw_data is not Array:
		return
	var raw_array: Array = raw_data

	for army_data: Variant in raw_array:
		_load_army_from_raw_data(army_data, game, project_textures)


static func to_raw_array(armies_list: Array[Army]) -> Array:
	var output: Array = []

	for army in armies_list:
		# Note:
		# We always save the army size even though it has a default value.
		# This is so that lowering the minimum army size
		# directly in the save file doesn't affect any army's size.
		var army_data: Dictionary = {
			_ID_KEY: army.id,
			_OWNER_ID_KEY: army.owner_country.id,
			_SIZE_KEY: army.size().value,
		}

		# Texture
		var texture_data: Variant = army.texture.to_raw_data()
		if texture_data != null:
			army_data.merge({ _TEXTURE_KEY: texture_data })

		# Province id
		if army.province_id() != -1:
			army_data.merge({ _PROVINCE_ID_KEY: army.province_id() })

		# Movements made
		if army.movements_made() != 0:
			army_data.merge({ _MOVEMENTS_KEY: army.movements_made() })

		output.append(army_data)

	return output


static func _load_army_from_raw_data(
		raw_data: Variant, game: Game, project_textures: ProjectTextures
) -> void:
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

	# Texture (optional, defaults to none)
	var texture: ProjectTexture = ProjectTextureParsing.texture_from_raw_data(
			raw_dict.get(_TEXTURE_KEY), project_textures
	)

	# Army size (optional, defaults to the minimum army size)
	# Note: if army size is smaller than the minimum,
	# the army is immediately destroyed upon creation.
	var army_size: int = game.rules.minimum_army_size.value
	if ParseUtils.dictionary_has_number(raw_dict, _SIZE_KEY):
		army_size = ParseUtils.dictionary_int(raw_dict, _SIZE_KEY)

	# Province (optional, defaults to no province)
	var province_id: int = -1
	if ParseUtils.dictionary_has_number(raw_dict, _PROVINCE_ID_KEY):
		province_id = ParseUtils.dictionary_int(raw_dict, _PROVINCE_ID_KEY)

	# Movements made (optional, defaults to 0)
	var movements_made: int = 0
	if ParseUtils.dictionary_has_number(raw_dict, _MOVEMENTS_KEY):
		movements_made = ParseUtils.dictionary_int(raw_dict, _MOVEMENTS_KEY)

	var new_army: Army = Army.Factory.new(game).new_army(
			owner_country, province_id, army_size, id, movements_made
	)
	new_army.texture = texture
