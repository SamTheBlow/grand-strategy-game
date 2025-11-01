class_name ProvinceParsing
## Parses raw data from/to [Province] instances.

const _ID_KEY: String = "id"
const _NAME_KEY: String = "name"
const _LINKS_KEY: String = "links"
const _POSITION_ARMY_HOST_X_KEY: String = "position_army_host_x"
const _POSITION_ARMY_HOST_Y_KEY: String = "position_army_host_y"
const _SHAPE_KEY: String = "shape"
const _POSITION_KEY: String = "position"
const _POS_X_KEY: String = "x"
const _POS_Y_KEY: String = "y"
const _OWNER_ID_KEY: String = "owner_country_id"
const _POPULATION_KEY: String = "population"
const _BUILDINGS_KEY: String = "buildings"
const _INCOME_MONEY_KEY: String = "income_money"

# Specific to province shape data
const _SHAPE_X_KEY: String = "x"
const _SHAPE_Y_KEY: String = "y"

# Specific to [Population] data
const _POPULATION_SIZE_KEY: String = "size"

# Specific to [Building] data
const _BUILDING_TYPE_KEY: String = "type"
const _BUILDING_TYPE_FORTRESS: String = "fortress"


## NOTE: Given game's countries must already be loaded before using this.
##
## Clears already existing provinces in given game.
##
## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
## Discards provinces with an already-in-use id.
static func load_from_raw_data(raw_data: Variant, game: Game) -> void:
	game.world.provinces.clear()

	if raw_data is not Array:
		return
	var raw_array: Array = raw_data

	for province_data: Variant in raw_array:
		_load_province_from_raw(province_data, game)

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


static func to_raw_array(province_list: Array[Province]) -> Array:
	var output: Array = []

	for province in province_list:
		var province_data: Dictionary = { _ID_KEY: province.id }

		# Name
		if province.name != "":
			province_data.merge({ _NAME_KEY: province.name })

		# Owner country
		if province.owner_country != null:
			province_data.merge({ _OWNER_ID_KEY: province.owner_country.id })

		# Links
		if not province.linked_province_ids().is_empty():
			province_data.merge({
				_LINKS_KEY: Array(province.linked_province_ids().duplicate())
			})

		# Shape
		if province.polygon().array != Province.default_shape():
			var shape_vertices_x: Array = []
			var shape_vertices_y: Array = []
			for i in province.polygon().array.size():
				shape_vertices_x.append(province.polygon().array[i].x)
				shape_vertices_y.append(province.polygon().array[i].y)
			province_data.merge({
				_SHAPE_KEY: {
					_SHAPE_X_KEY: shape_vertices_x,
					_SHAPE_Y_KEY: shape_vertices_y,
				}
			})

		# Position army host
		if province.position_army_host.x != 0.0:
			province_data.merge({
				_POSITION_ARMY_HOST_X_KEY: province.position_army_host.x
			})
		if province.position_army_host.y != 0.0:
			province_data.merge({
				_POSITION_ARMY_HOST_Y_KEY: province.position_army_host.y
			})

		# Population
		if province.population().value != 0:
			province_data.merge({
				_POPULATION_KEY:
					{ _POPULATION_SIZE_KEY: province.population().value }
			})

		# Money income
		if province.base_money_income().value != 0:
			province_data.merge(
					{ _INCOME_MONEY_KEY: province.base_money_income().value }
			)

		# Buildings
		var buildings_data: Array = []
		for building in province.buildings.list():
			# 4.0 backwards compatibility: building type must be a string.
			buildings_data.append(
					{ _BUILDING_TYPE_KEY: _BUILDING_TYPE_FORTRESS }
			)
		if not buildings_data.is_empty():
			province_data.merge({ _BUILDINGS_KEY: buildings_data })

		output.append(province_data)

	return output


static func _load_province_from_raw(raw_data: Variant, game: Game) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	# Province id (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, _ID_KEY):
		return
	var id: int = ParseUtils.dictionary_int(raw_dict, _ID_KEY)

	# The id must be valid and available.
	if not game.world.provinces._unique_id_system.is_id_available(id):
		return

	var province := Province.new()
	province.id = id

	# Name
	if ParseUtils.dictionary_has_string(raw_dict, _NAME_KEY):
		province.name = raw_dict[_NAME_KEY]

	# Links
	if ParseUtils.dictionary_has_array(raw_dict, _LINKS_KEY):
		var links_array: Array = raw_dict[_LINKS_KEY]
		for link_data: Variant in links_array:
			if ParseUtils.is_number(link_data):
				province.linked_province_ids().append(
						ParseUtils.number_as_int(link_data)
				)

	# Shape
	province.polygon().array = (
			_province_shape_from_raw(raw_dict.get(_SHAPE_KEY))
	)

	# Position of the host army
	province.position_army_host = _position_army_host_from_raw(raw_dict)

	# Owner country
	if ParseUtils.dictionary_has_number(raw_dict, _OWNER_ID_KEY):
		var country_id: int = (
				ParseUtils.dictionary_int(raw_dict, _OWNER_ID_KEY)
		)
		province.owner_country = game.countries.country_from_id(country_id)

	# Population
	province.population().value = (
			_population_from_raw(raw_dict.get(_POPULATION_KEY))
	)

	# Money income
	if ParseUtils.dictionary_has_number(raw_dict, _INCOME_MONEY_KEY):
		province.base_money_income().value = (
				ParseUtils.dictionary_int(raw_dict, _INCOME_MONEY_KEY)
		)

	# Buildings
	if ParseUtils.dictionary_has_array(raw_dict, _BUILDINGS_KEY):
		var raw_buildings_array: Array = raw_dict[_BUILDINGS_KEY]
		for building_data: Variant in raw_buildings_array:
			if building_data is not Dictionary:
				continue
			var building_dict: Dictionary = building_data

			if (
					building_dict.get(_BUILDING_TYPE_KEY)
					== _BUILDING_TYPE_FORTRESS
			):
				province.buildings.add(Fortress.new(province.id))

	# Position offset (DEPRECATED)
	var offset: Vector2 = (
			_province_position_from_raw(raw_dict.get(_POSITION_KEY))
	)
	province.position_army_host -= offset
	province.move_relative(offset)

	game.world.provinces.add(province)


static func _province_shape_from_raw(raw_data: Variant) -> PackedVector2Array:
	if raw_data is not Dictionary:
		return Province.default_shape()
	var raw_dict: Dictionary = raw_data

	var shape_x_array: Array = []
	if ParseUtils.dictionary_has_array(raw_dict, _SHAPE_X_KEY):
		shape_x_array = raw_dict[_SHAPE_X_KEY]

	var shape_y_array: Array = []
	if ParseUtils.dictionary_has_array(raw_dict, _SHAPE_Y_KEY):
		shape_y_array = raw_dict[_SHAPE_Y_KEY]

	# If one has more points than the other, ignore the extra points
	var number_of_points: int = (
			mini(shape_x_array.size(), shape_y_array.size())
	)

	if number_of_points < 3:
		return Province.default_shape()

	var shape: PackedVector2Array = []
	for i in number_of_points:
		shape.append(Vector2(shape_x_array[i], shape_y_array[i]))

	return shape


static func _province_position_from_raw(raw_data: Variant) -> Vector2:
	if raw_data is not Dictionary:
		return Vector2.ZERO
	var raw_dict: Dictionary = raw_data

	var position_x_data: Variant = raw_dict.get(_POS_X_KEY)
	var position_x: float = 0.0
	if ParseUtils.is_number(position_x_data):
		position_x = ParseUtils.number_as_float(position_x_data)

	var position_y_data: Variant = raw_dict.get(_POS_Y_KEY)
	var position_y: float = 0.0
	if ParseUtils.is_number(position_y_data):
		position_y = ParseUtils.number_as_float(position_y_data)

	return Vector2(position_x, position_y)


static func _position_army_host_from_raw(raw_dict: Dictionary) -> Vector2:
	var x_data: Variant = raw_dict.get(_POSITION_ARMY_HOST_X_KEY)
	var position_x: float = 0.0
	if ParseUtils.is_number(x_data):
		position_x = ParseUtils.number_as_float(x_data)

	var y_data: Variant = raw_dict.get(_POSITION_ARMY_HOST_Y_KEY)
	var position_y: float = 0.0
	if ParseUtils.is_number(y_data):
		position_y = ParseUtils.number_as_float(y_data)

	return Vector2(position_x, position_y)


static func _population_from_raw(raw_data: Variant) -> int:
	if raw_data is not Dictionary:
		return 0
	var raw_dict: Dictionary = raw_data

	if ParseUtils.dictionary_has_number(raw_dict, _POPULATION_SIZE_KEY):
		return maxi(
				0, ParseUtils.dictionary_int(raw_dict, _POPULATION_SIZE_KEY)
		)

	return 0
