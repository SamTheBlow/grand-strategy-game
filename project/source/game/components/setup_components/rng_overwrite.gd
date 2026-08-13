class_name RNGOverwrite
extends GameComponent
## Overwrites the game's RNG seed according to the game rules.

const KEY: String = "rng_overwrite"


func _init() -> void:
	priority_index = 1


func run(game: Game) -> void:
	if game.rules.rng_seed_override_enabled.value:
		game.rng.rng_seed = game.rules.rng_seed.value
