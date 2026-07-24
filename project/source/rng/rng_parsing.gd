class_name RNGParsing
## Parses raw data from/to a [GameRNG].

const _SEED_KEY: String = "seed"
const _STATE_KEY: String = "state"


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_data(raw_data: Variant) -> GameRNG:
	var rng := GameRNG.new()

	if raw_data is not Dictionary:
		return rng
	var raw_dict: Dictionary = raw_data

	if ParseUtils.dictionary_has_string(raw_dict, _SEED_KEY):
		rng.rng_seed = raw_dict[_SEED_KEY]

		# If there is no seed data,
		# then the state is irrelevant and must be discarded
		if ParseUtils.dictionary_has_string(raw_dict, _STATE_KEY):
			rng.rng_state = raw_dict[_STATE_KEY]

	return rng


static func to_raw_dict(rng: GameRNG) -> Dictionary:
	var output: Dictionary = {}

	if rng.rng_seed != "":
		output.merge({ _SEED_KEY: rng.rng_seed })

		# If it's a random seed,
		# then the state is irrelevant and must be discarded
		if rng.rng_state != "":
			output.merge({ _STATE_KEY: rng.rng_state })

	return output
