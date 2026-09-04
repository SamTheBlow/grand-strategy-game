class_name RNGParsing
## Parses raw data from/to a [GameRNG].

const _SEED_KEY: String = "seed"
const _STATE_KEY: String = "state"


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_data(
		raw_data: Variant, game_state: Game.GameState
) -> GameRNG:
	if game_state == Game.GameState.SETUP:
		return _from_raw_data_during_setup(raw_data)
	return _from_raw_data_after_setup(raw_data)


## During setup phase, the seed is a string of any form.
## When setup will end, this string will be hashed to produce a number.
## An empty string means random seed.
static func _from_raw_data_during_setup(raw_data: Variant) -> GameRNG:
	if raw_data is not Dictionary:
		return GameRNG.new()
	var raw_dict: Dictionary = raw_data

	# Discard state data if there is no seed data
	if not ParseUtils.dictionary_has_string(raw_dict, _SEED_KEY):
		return GameRNG.new()

	var loaded_seed: String = raw_dict[_SEED_KEY]
	var loaded_state: String = ""

	if ParseUtils.dictionary_has_string(raw_dict, _STATE_KEY):
		loaded_state = raw_dict[_STATE_KEY]

	var output := GameRNG.new()
	output.rng_seed = loaded_seed
	output.rng_state = loaded_state
	return output


## After setup phase, the seed is a number.
## It's the hashed form of whatever seed string the user gave during setup,
## or a random number if user asked for a random seed.
## The seed at this stage should not be missing or empty.
static func _from_raw_data_after_setup(raw_data: Variant) -> GameRNG:
	const WARNING_MESSAGE: String = (
		"Loaded an already started game with no RNG seed. "
		+ "The game will continue with a random seed."
	)

	if raw_data is not Dictionary:
		push_warning(WARNING_MESSAGE)
		return GameRNG.new(true)
	var raw_dict: Dictionary = raw_data

	# Discard state data if there is no seed data
	if not ParseUtils.dictionary_has_number(raw_dict, _SEED_KEY):
		push_warning(WARNING_MESSAGE)
		return GameRNG.new(true)

	# Discard state data if it isn't a number
	if ParseUtils.dictionary_has_number(raw_dict, _STATE_KEY):
		return GameRNG.new(
			true,
			true,
			ParseUtils.dictionary_int(raw_dict, _SEED_KEY),
			true,
			ParseUtils.dictionary_int(raw_dict, _STATE_KEY)
		)

	return GameRNG.new(
			true,
			true,
			ParseUtils.dictionary_int(raw_dict, _SEED_KEY),
			false
	)


static func to_raw_dict(rng: GameRNG) -> Dictionary:
	var output: Dictionary = {}

	if rng.rng_seed != "":
		output.merge({ _SEED_KEY: rng.rng_seed })

		# If it's a random seed,
		# then the state is irrelevant and must be discarded
		if rng.rng_state != "":
			output.merge({ _STATE_KEY: rng.rng_state })

	return output
