class_name GameRNGStepCounted
extends GameRNG
## Counts how many steps are done to the RNG's state.

var _step_count: int = 0


## Optionally, copies given [GameRNG]'s internal state.
func _init(game_rng: GameRNG = null) -> void:
	if game_rng != null:
		_rng.seed = game_rng._rng.seed
		_rng.state = game_rng._rng.state
		_is_locked = game_rng._is_locked


## Returns the number of steps done on the RNG state since creation.
func step_count() -> int:
	return _step_count


## Exposes the internal [RandomNumberGenerator]'s method.
func randi() -> int:
	_step_count += 1
	return _rng.randi()


## Exposes the internal [RandomNumberGenerator]'s method.
func randf() -> float:
	_step_count += 2
	return _rng.randf()


## Exposes the internal [RandomNumberGenerator]'s method.
func randi_range(from: int, to: int) -> int:
	if from == to:
		return from
	_step_count += 1
	return _rng.randi_range(from, to)
