class_name RNGFromRaw
## Converts raw data into a [RandomNumberGenerator] instance.
##
## This operation always succeeds.
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.

const KEY_SEED: String = "seed"
const KEY_STATE: String = "state"


static func parsed_from(raw_data: Variant) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()

	if raw_data is not Dictionary:
		return rng
	var raw_dict: Dictionary = raw_data

	if ParseUtils.dictionary_has_number(raw_dict, KEY_SEED):
		rng.seed = ParseUtils.dictionary_int(raw_dict, KEY_SEED)

	if ParseUtils.dictionary_has_number(raw_dict, KEY_STATE):
		rng.state = ParseUtils.dictionary_int(raw_dict, KEY_STATE)

	return rng
