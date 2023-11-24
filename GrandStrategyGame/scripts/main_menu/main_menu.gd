class_name MainMenu
extends Node


signal game_started(scenario: PackedScene, rules: GameRules)


func _on_start_game_requested(scenario: PackedScene, rules: GameRules) -> void:
	game_started.emit(scenario, rules)
