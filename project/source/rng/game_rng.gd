class_name GameRNG
## A [Game]'s RNG. Has useful signals.

signal seed_changed(before: String, after: String)
signal state_changed(before: String, after: String)

## An empty string means it'll be a random seed when the game starts.
## After locking, this variable can no longer be changed
## and instead returns the underlying hashed seed.
var rng_seed: String = "":
	get:
		if _is_locked :
			return str(_rng.seed)
		return rng_seed
	set(value):
		if _is_locked:
			push_warning("Tried to change RNG seed but the RNG is locked")
			return

		var old_seed: String = rng_seed
		var old_state: int = _rng.state

		if old_seed == value:
			return

		rng_seed = value

		if rng_seed == "":
			_rng.randomize()
		else:
			_rng.seed = hash(value)

		seed_changed.emit(old_seed, value)
		if old_state != _rng.state:
			rng_state = ""

## An empty string means it'll be the seed's initial state.
## After locking, this variable can no longer be changed
## and instead returns the underlying RNG's current state.
var rng_state: String = "":
	get:
		if _is_locked:
			return str(_rng.state)
		return rng_state
	set(new_state):
		if _is_locked:
			push_warning("Tried to change RNG state but the RNG is locked")
			return

		var old_state: String = rng_state

		if old_state == new_state:
			return

		rng_state = new_state

		if new_state == "":
			# This resets the state without changing the seed
			_rng.seed = _rng.seed
		else:
			_rng.state = new_state.to_int()

		state_changed.emit(old_state, new_state)

var _is_locked: bool = false
var _rng := RandomNumberGenerator.new()


## Allows you to provide an initial seed (hashed) and state.
func _init(
		has_initial_seed: bool = false,
		initial_seed: int = 0,
		has_initial_state: bool = false,
		initial_state: int = 0
) -> void:
	if has_initial_seed:
		_rng.seed = initial_seed
		if has_initial_state:
			_rng.state = initial_state


## Exposes the internal [RandomNumberGenerator]'s method.
func randi() -> int:
	return _rng.randi()


## Exposes the internal [RandomNumberGenerator]'s method.
func randf() -> float:
	return _rng.randf()


## Exposes the internal [RandomNumberGenerator]'s method.
func randi_range(from: int, to: int) -> int:
	return _rng.randi_range(from, to)


## Locks the rng_seed and rng_state values so that they can't be changed.
func lock() -> void:
	_is_locked = true
