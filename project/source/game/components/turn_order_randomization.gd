class_name TurnOrderRandomization
extends GameComponent
## Shuffles the country turn order.

const KEY: String = "turn_order_randomization"


func _init() -> void:
	priority_index = 60


## Registers this component to run at the end of the setup phase.
func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	game.countries.shuffle_order(game.rng)
