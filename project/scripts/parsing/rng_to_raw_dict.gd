class_name RNGToRawDict
## Converts a given [RandomNumberGenerator] into a raw [Dictionary].
# The seed and state are being saved as strings, to avoid precision loss.
# See [ParseUtils] for explanation.


func result(rng: RandomNumberGenerator) -> Dictionary:
	return {
		RNGFromRawDict.KEY_SEED: str(rng.seed),
		RNGFromRawDict.KEY_STATE: str(rng.state),
	}
