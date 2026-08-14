class_name RNGOverwrite
extends GameComponent
## Overwrites the game's RNG seed according to the game rules.

const KEY: String = "rng_overwrite"


func _init() -> void:
	priority_index = 1


## Registers this component to run at the end of the setup phase.
func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	if game.rules.rng_seed_override_enabled.value:
		game.rng.rng_seed = game.rules.rng_seed.value
