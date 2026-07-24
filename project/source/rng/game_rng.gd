class_name GameRNG
## A [Game]'s RNG. Has useful signals.

signal seed_changed(before: String, after: String)
signal state_changed(before: String, after: String)

## An empty string means it'll be a random seed when the game starts.
var rng_seed: String = "":
	set(value):
		var old_seed: String = rng_seed
		var old_state: int = _rng.state

		if old_seed == value:
			return

		rng_seed = value
		_rng.seed = hash(value)

		seed_changed.emit(old_seed, value)
		if old_state != _rng.state:
			rng_state = str(_rng.state)

## An empty string means it'll be a random state when the game starts.
## When setting this value,
## turns the value into an integer and then back into a string.
var rng_state: String = "":
	set(new_state):
		var old_state: String = rng_state

		if old_state == new_state:
			return

		if new_state != "":
			_rng.state = new_state.to_int()
			new_state = str(_rng.state)

		if old_state == new_state:
			return

		rng_state = new_state
		state_changed.emit(old_state, new_state)

var _rng: RandomNumberGenerator


func _init(rng := RandomNumberGenerator.new()) -> void:
	_rng = rng
