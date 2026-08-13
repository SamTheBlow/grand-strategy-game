class_name TurnOrderRandomization
extends GameComponent
## Shuffles the country turn order.

const ID: int = 9


func _init() -> void:
	priority_index = 60


func id() -> int:
	return ID


func run(game: Game) -> void:
	game.countries.shuffle_order(game.rng)
