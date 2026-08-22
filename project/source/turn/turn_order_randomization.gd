class_name TurnOrderRandomization
extends GameComponent
## During game setup, shuffles the country turn order.

const KEY: String = "turn_order_randomization"
const TITLE: String = "Turn Order Randomization"
const DESCRIPTION: String = "During game setup, shuffles the country turn order."
const SETTINGS: Array = []


func _init() -> void:
	priority_index = 60


## Registers this component to run at the end of the setup phase.
func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	game.countries.shuffle_order(game.rng)
