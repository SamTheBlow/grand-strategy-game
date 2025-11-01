class_name RNGParsing
## Parses raw data from/to a [RandomNumberGenerator].

const _SEED_KEY: String = "seed"
const _STATE_KEY: String = "state"


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_data(raw_data: Variant) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()

	if raw_data is not Dictionary:
		return rng
	var raw_dict: Dictionary = raw_data

	if ParseUtils.dictionary_has_number(raw_dict, _SEED_KEY):
		rng.seed = ParseUtils.dictionary_int(raw_dict, _SEED_KEY)

	if ParseUtils.dictionary_has_number(raw_dict, _STATE_KEY):
		rng.state = ParseUtils.dictionary_int(raw_dict, _STATE_KEY)

	return rng


static func to_raw_data(rng: RandomNumberGenerator) -> Variant:
	# Saves the values as strings, to avoid precision loss.
	# See [ParseUtils] for explanation.
	return {
		_SEED_KEY: str(rng.seed),
		_STATE_KEY: str(rng.state),
	}
