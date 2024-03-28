class_name MainMenu
extends Node


signal game_started(scenario: PackedScene, rules: GameRules)


## Dependency injection: passes the players node to the player list.
func setup_players(players: Players) -> void:
	(%Lobby as Lobby).player_list.players = players


func _on_start_game_requested(scenario: PackedScene, rules: GameRules) -> void:
	game_started.emit(scenario, rules)
