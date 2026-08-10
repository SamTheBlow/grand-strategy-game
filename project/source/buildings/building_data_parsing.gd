class_name BuildingDataParsing

const _NAME_KEY: String = "name"
const _TEXTURE_KEY: String = "texture"
const _DEFENSE_MULT_KEY: String = "defense_multiplier"
const _CAN_BE_BUILT_KEY: String = "can_be_built"
const _POPULATION_COST_KEY: String = "population_cost"
const _MONEY_COST_KEY: String = "money_cost"


static func from_raw_data(
		raw_data: Variant, project_textures: ProjectTextures
) -> Array[BuildingData]:
	var output: Array[BuildingData] = []

	if raw_data is not Array:
		return output
	var raw_array := raw_data as Array

	for raw_element: Variant in raw_array:
		if raw_element is not Dictionary:
			continue
		var raw_dict := raw_element as Dictionary

		var new_data := BuildingData.new()

		if ParseUtils.dictionary_has_string(raw_dict, _NAME_KEY):
			new_data.building_name = raw_dict[_NAME_KEY]

		if raw_dict.has(_TEXTURE_KEY):
			new_data.texture = ProjectTextureParsing.texture_from_raw_data(
					raw_dict[_TEXTURE_KEY], project_textures
			)

		if ParseUtils.dictionary_has_number(raw_dict, _DEFENSE_MULT_KEY):
			new_data.defense_multiplier = (
					ParseUtils.dictionary_float(raw_dict, _DEFENSE_MULT_KEY)
			)

		if ParseUtils.dictionary_has_bool(raw_dict, _CAN_BE_BUILT_KEY):
			new_data.can_be_built = raw_dict[_CAN_BE_BUILT_KEY]

		if ParseUtils.dictionary_has_number(raw_dict, _POPULATION_COST_KEY):
			new_data.population_cost = (
					ParseUtils.dictionary_int(raw_dict, _POPULATION_COST_KEY)
			)

		if ParseUtils.dictionary_has_number(raw_dict, _MONEY_COST_KEY):
			new_data.money_cost = (
					ParseUtils.dictionary_int(raw_dict, _MONEY_COST_KEY)
			)

		output.append(new_data)

	return output


static func to_raw_array(building_data: Array[BuildingData]) -> Array:
	var output: Array = []

	for element in building_data:
		var raw_dict: Dictionary = {
			_TEXTURE_KEY: element.texture.to_raw_data()
		}

		if element.building_name != "":
			raw_dict[_NAME_KEY] = element.building_name

		if raw_dict[_TEXTURE_KEY] == null:
			raw_dict.erase(_TEXTURE_KEY)

		if element.defense_multiplier != 1.0:
			raw_dict[_DEFENSE_MULT_KEY] = element.defense_multiplier

		if element.can_be_built != true:
			raw_dict[_CAN_BE_BUILT_KEY] = element.can_be_built

		if element.population_cost != 0:
			raw_dict[_POPULATION_COST_KEY] = element.population_cost

		if element.money_cost != 0:
			raw_dict[_MONEY_COST_KEY] = element.money_cost

		output.append(raw_dict)

	return output
