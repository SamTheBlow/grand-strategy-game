class_name ProvincesFromRaw
## Converts raw data into [Provinces].
## Many things in the game must be loaded before using this.
## Please read the code carefully to know what to load first (sorry!)
##
## This operation always succeeds.
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.
## Discards provinces with an already-in-use id.

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


static func parse_using(raw_data: Variant, game: Game) -> void:
	if raw_data is not Array:
		return
	var raw_array: Array = raw_data

	for province_data: Variant in raw_array:
		_parse_province(province_data, game)

	# Validate province links (needs to be done after all provinces are loaded)
	for province in game.world.provinces._list:
		var link_list: Array[int] = province.linked_province_ids().duplicate()
		for linked_province_id in link_list:
			if (
					game.world.provinces
					.province_from_id(linked_province_id) == null
			):
				province.linked_province_ids().erase(linked_province_id)


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
	province.polygon = _parsed_province_shape(raw_dict.get(PROVINCE_SHAPE_KEY))

	# Position
	province.position = (
			_parsed_province_position(raw_dict.get(PROVINCE_POSITION_KEY))
	)

	# Position of the host army
	province.position_army_host = _parsed_position_army_host(raw_dict, province)

	# Owner country
	if ParseUtils.dictionary_has_number(raw_dict, PROVINCE_OWNER_ID_KEY):
		var country_id: int = (
				ParseUtils.dictionary_int(raw_dict, PROVINCE_OWNER_ID_KEY)
		)
		province.owner_country = game.countries.country_from_id(country_id)

	# Population
	_parse_population(raw_dict.get(PROVINCE_POPULATION_KEY), game, province)

	# Buildings
	if ParseUtils.dictionary_has_array(raw_dict, PROVINCE_BUILDINGS_KEY):
		var raw_buildings_array: Array = raw_dict[PROVINCE_BUILDINGS_KEY]
		for building_data: Variant in raw_buildings_array:
			if building_data is not Dictionary:
				continue
			var building_dict: Dictionary = building_data

			if building_dict.get(BUILDING_TYPE_KEY) == BUILDING_TYPE_FORTRESS:
				province.buildings.add(Fortress.new_fortress(game, province))

	# Money income
	if (
			game.rules.province_income_option.selected_value()
			== GameRules.ProvinceIncome.POPULATION
	):
		province._income_money = IncomeMoneyPerPopulation.new(
				province.population,
				game.rules.province_income_per_person.value
		)
	else:
		var base_income: int = 0
		if ParseUtils.dictionary_has_number(raw_dict, PROVINCE_INCOME_MONEY_KEY):
			base_income = ParseUtils.dictionary_int(
					raw_dict, PROVINCE_INCOME_MONEY_KEY
			)
		province._income_money = IncomeMoneyConstant.new(base_income)

	game.world.provinces.add(province)
	province.add_component(ArmyReinforcements.new(game, province))
	province.add_component(IncomeEachTurn.new(province, game.turn.turn_changed))
	province.add_component(ProvinceOwnershipUpdate.new(
			province,
			game.world.armies_in_each_province.in_province(province),
			game.turn.player_turn_ended
	))


static func _parsed_province_shape(raw_data: Variant) -> PackedVector2Array:
	if raw_data is not Dictionary:
		return []
	var raw_dict: Dictionary = raw_data

	var shape_x_array: Array = []
	if ParseUtils.dictionary_has_array(raw_dict, PROVINCE_SHAPE_X_KEY):
		shape_x_array = raw_dict[PROVINCE_SHAPE_X_KEY]

	var shape_y_array: Array = []
	if ParseUtils.dictionary_has_array(raw_dict, PROVINCE_SHAPE_Y_KEY):
		shape_y_array = raw_dict[PROVINCE_SHAPE_Y_KEY]

	# If one has more points than the other, ignore the extra points
	var number_of_points: int = mini(shape_x_array.size(), shape_y_array.size())

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


static func _parsed_position_army_host(
		raw_dict: Dictionary, province: Province
) -> Vector2:
	var x_data: Variant = raw_dict.get(PROVINCE_POSITION_ARMY_HOST_X_KEY)
	var position_x: float = 0.0
	if ParseUtils.is_number(x_data):
		position_x = ParseUtils.number_as_float(x_data)

	var y_data: Variant = raw_dict.get(PROVINCE_POSITION_ARMY_HOST_Y_KEY)
	var position_y: float = 0.0
	if ParseUtils.is_number(y_data):
		position_y = ParseUtils.number_as_float(y_data)

	# 4.1 Backwards Compatibility:
	# This must be saved as a global position
	# (not relative to the province position).
	return Vector2(position_x, position_y) - province.position


static func _parse_population(
		raw_data: Variant, game: Game, province: Province
) -> void:
	province.population = Population.new(game)

	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	var population_size: int = 0
	if ParseUtils.dictionary_has_number(raw_dict, POPULATION_SIZE_KEY):
		population_size = (
				ParseUtils.dictionary_int(raw_dict, POPULATION_SIZE_KEY)
		)

	province.population.population_size = population_size
