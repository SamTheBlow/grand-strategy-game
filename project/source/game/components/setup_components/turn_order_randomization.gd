class_name TurnOrderRandomization
extends GameComponent
## Shuffles the country turn order.

const KEY: String = "turn_order_randomization"


func _init() -> void:
	priority_index = 60


func run(game: Game) -> void:
	game.countries.shuffle_order(game.rng)
