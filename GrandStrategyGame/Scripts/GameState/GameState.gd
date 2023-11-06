class_name GameState
extends Node


signal game_over(Country)
signal province_selected(Province)

# Nodes
var rules: Rules
var countries: Countries
var players: Players
var world: GameWorld

# Other data
var turn := GameTurn.new()


func setup() -> void:
	rules.setup()
	rules.connect("game_over", Callable(self, "_on_game_over"))


func _on_game_over(winner: Country) -> void:
	game_over.emit(winner)


func connect_to_provinces(callable: Callable) -> void:
	world.connect_to_provinces(callable)


func copy() -> GameState:
	var builder := GameStateFromJSON.new(as_JSON())
	builder.build()
	builder.game_state.setup()
	return builder.game_state


func as_JSON() -> Dictionary:
	return {
		"rules": rules.as_JSON(),
		"countries": countries.as_JSON(),
		"players": players.as_JSON(),
		"world": world.as_JSON(),
		"turn": turn.as_JSON(),
	}
