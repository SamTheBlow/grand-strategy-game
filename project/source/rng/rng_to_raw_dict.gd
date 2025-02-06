class_name RNGToRawDict
## Converts a given [RandomNumberGenerator] into a raw [Dictionary].


func result(rng: RandomNumberGenerator) -> Dictionary:
	# Saves the values as strings, to avoid precision loss.
	# See [ParseUtils] for explanation.
	return {
		RNGFromRaw.KEY_SEED: str(rng.seed),
		RNGFromRaw.KEY_STATE: str(rng.state),
	}
