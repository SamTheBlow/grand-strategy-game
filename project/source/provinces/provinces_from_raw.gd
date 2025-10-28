class_name ProvincesFromRaw
## Converts raw data into [Provinces].

const PROVINCE_ID_KEY: String = "id"
const PROVINCE_NAME_KEY: String = "name"
const PROVINCE_LINKS_KEY: String = "links"
const PROVINCE_POSITION_ARMY_HOST_X_KEY: String = "position_army_host_x"
const PROVINCE_POSITION_ARMY_HOST_Y_KEY: String = "position_army_host_y"
const PROVINCE_SHAPE_KEY: String = "shape"
const PROVINCE_POSITION_KEY: String = "position"
const PROVINCE_POS_X_KEY: String = "x"
const PROVINCE_POS_Y_KEY: String = "y"
const PROVINCE_OWNER_ID_KEY: String = "owner_country_id"
const PROVINCE_POPULATION_KEY: String = "population"
const PROVINCE_BUILDINGS_KEY: String = "buildings"
const PROVINCE_INCOME_MONEY_KEY: String = "income_money"

# Specific to province shape data
const PROVINCE_SHAPE_X_KEY: String = "x"
const PROVINCE_SHAPE_Y_KEY: String = "y"

# Specific to [Population] data
const POPULATION_SIZE_KEY: String = "size"

# Specific to [Building] data
const BUILDING_TYPE_KEY: String = "type"
const BUILDING_TYPE_FORTRESS: String = "fortress"


## Always succeeds.
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.
## Discards provinces with an already-in-use id.
##
## Clears already existing provinces in given game.
##
## NOTE: Countries must already be loaded before using this.
static func parse_using(raw_data: Variant, game: Game) -> void:
	game.world.provinces.clear()

	if raw_data is not Array:
		return
	var raw_array: Array = raw_data

	for province_data: Variant in raw_array:
		_parse_province(province_data, game)

	# Validate province links (needs to be done after all provinces are loaded)
	for province_id in game.world.provinces._list:
		var link_list: Array[int] = (
				game.world.provinces._list[province_id]
				.linked_province_ids()
		)
		for i in link_list.size():
			if not game.world.provinces._list.has(link_list[i]):
				link_list.remove_at(i)
				i -= 1


static func _parse_province(raw_data: Variant, game: Game) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	# Province id (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, PROVINCE_ID_KEY):
		return
	var id: int = ParseUtils.dictionary_int(raw_dict, PROVINCE_ID_KEY)

	# The id must be valid and available.
	if not game.world.provinces._unique_id_system.is_id_available(id):
		return

	var province := Province.new()
	province.id = id

	# Name
	if ParseUtils.dictionary_has_string(raw_dict, PROVINCE_NAME_KEY):
		province.name = raw_dict[PROVINCE_NAME_KEY]

	# Links
	if ParseUtils.dictionary_has_array(raw_dict, PROVINCE_LINKS_KEY):
		var links_array: Array = raw_dict[PROVINCE_LINKS_KEY]
		for link_data: Variant in links_array:
			if ParseUtils.is_number(link_data):
				province.linked_province_ids().append(
						ParseUtils.number_as_int(link_data)
				)

	# Shape
	province.polygon().array = (
			_parsed_province_shape(raw_dict.get(PROVINCE_SHAPE_KEY))
	)

	# Position of the host army
	province.position_army_host = _parsed_position_army_host(raw_dict)

	# Owner country
	if ParseUtils.dictionary_has_number(raw_dict, PROVINCE_OWNER_ID_KEY):
		var country_id: int = (
				ParseUtils.dictionary_int(raw_dict, PROVINCE_OWNER_ID_KEY)
		)
		province.owner_country = game.countries.country_from_id(country_id)

	# Population
	province.population().value = (
			_parsed_population(raw_dict.get(PROVINCE_POPULATION_KEY))
	)

	# Money income
	if ParseUtils.dictionary_has_number(raw_dict, PROVINCE_INCOME_MONEY_KEY):
		province.base_money_income().value = (
				ParseUtils.dictionary_int(raw_dict, PROVINCE_INCOME_MONEY_KEY)
		)

	# Buildings
	if ParseUtils.dictionary_has_array(raw_dict, PROVINCE_BUILDINGS_KEY):
		var raw_buildings_array: Array = raw_dict[PROVINCE_BUILDINGS_KEY]
		for building_data: Variant in raw_buildings_array:
			if building_data is not Dictionary:
				continue
			var building_dict: Dictionary = building_data

			if building_dict.get(BUILDING_TYPE_KEY) == BUILDING_TYPE_FORTRESS:
				province.buildings.add(Fortress.new(province.id))

	# Position offset (DEPRECATED)
	var offset: Vector2 = (
			_parsed_province_position(raw_dict.get(PROVINCE_POSITION_KEY))
	)
	province.position_army_host -= offset
	province.move_relative(offset)

	game.world.provinces.add(province)


static func _parsed_province_shape(raw_data: Variant) -> PackedVector2Array:
	if raw_data is not Dictionary:
		return Province.default_shape()
	var raw_dict: Dictionary = raw_data

	var shape_x_array: Array = []
	if ParseUtils.dictionary_has_array(raw_dict, PROVINCE_SHAPE_X_KEY):
		shape_x_array = raw_dict[PROVINCE_SHAPE_X_KEY]

	var shape_y_array: Array = []
	if ParseUtils.dictionary_has_array(raw_dict, PROVINCE_SHAPE_Y_KEY):
		shape_y_array = raw_dict[PROVINCE_SHAPE_Y_KEY]

	# If one has more points than the other, ignore the extra points
	var number_of_points: int = mini(shape_x_array.size(), shape_y_array.size())

	if number_of_points < 3:
		return Province.default_shape()

	var shape: PackedVector2Array = []
	for i in number_of_points:
		shape.append(Vector2(shape_x_array[i], shape_y_array[i]))

	return shape


static func _parsed_province_position(raw_data: Variant) -> Vector2:
	if raw_data is not Dictionary:
		return Vector2.ZERO
	var raw_dict: Dictionary = raw_data

	var position_x_data: Variant = raw_dict.get(PROVINCE_POS_X_KEY)
	var position_x: float = 0.0
	if ParseUtils.is_number(position_x_data):
		position_x = ParseUtils.number_as_float(position_x_data)

	var position_y_data: Variant = raw_dict.get(PROVINCE_POS_Y_KEY)
	var position_y: float = 0.0
	if ParseUtils.is_number(position_y_data):
		position_y = ParseUtils.number_as_float(position_y_data)

	return Vector2(position_x, position_y)


static func _parsed_position_army_host(raw_dict: Dictionary) -> Vector2:
	var x_data: Variant = raw_dict.get(PROVINCE_POSITION_ARMY_HOST_X_KEY)
	var position_x: float = 0.0
	if ParseUtils.is_number(x_data):
		position_x = ParseUtils.number_as_float(x_data)

	var y_data: Variant = raw_dict.get(PROVINCE_POSITION_ARMY_HOST_Y_KEY)
	var position_y: float = 0.0
	if ParseUtils.is_number(y_data):
		position_y = ParseUtils.number_as_float(y_data)

	return Vector2(position_x, position_y)


static func _parsed_population(raw_data: Variant) -> int:
	if raw_data is not Dictionary:
		return 0
	var raw_dict: Dictionary = raw_data

	if ParseUtils.dictionary_has_number(raw_dict, POPULATION_SIZE_KEY):
		return maxi(
				0, ParseUtils.dictionary_int(raw_dict, POPULATION_SIZE_KEY)
		)

	return 0
