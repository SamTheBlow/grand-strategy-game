class_name ArmyDataParsing
## Parses raw data from/to an [ArmyData].

const _MINIMUM_KEY: String = "minimum_size"
const _MAXIMUM_KEY: String = "maximum_size"


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_data(raw_data: Variant) -> ArmyData:
	var output := ArmyData.new()

	if raw_data is not Dictionary:
		return output
	var raw_dict: Dictionary = raw_data

	if ParseUtils.dictionary_has_number(raw_dict, _MINIMUM_KEY):
		output.minimum_size = ParseUtils.dictionary_int(raw_dict, _MINIMUM_KEY)
	if ParseUtils.dictionary_has_number(raw_dict, _MAXIMUM_KEY):
		output.maximum_size = ParseUtils.dictionary_int(raw_dict, _MAXIMUM_KEY)

	return output


## Only includes values that differ from the defaults.
static func to_raw_dict(army_data: ArmyData) -> Dictionary:
	var output: Dictionary = {}

	if army_data.minimum_size > 1:
		output[_MINIMUM_KEY] = army_data.minimum_size
	if army_data.maximum_size >= 1:
		output[_MAXIMUM_KEY] = army_data.maximum_size

	return output
