class_name RNGFromRawDict
## Converts given raw [Dictionary] into a [RandomNumberGenerator] instance.

const KEY_SEED: String = "seed"
const KEY_STATE: String = "state"


func result(raw_dict: Dictionary) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()

	if ParseUtils.dictionary_has_number(raw_dict, KEY_SEED):
		rng.seed = ParseUtils.dictionary_int(raw_dict, KEY_SEED)

	if ParseUtils.dictionary_has_number(raw_dict, KEY_STATE):
		rng.state = ParseUtils.dictionary_int(raw_dict, KEY_STATE)

	return rng
