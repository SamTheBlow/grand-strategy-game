class_name Lobby
extends Control


signal start_game_requested(scenario: PackedScene, rules: GameRules)


@export var scenario_scene: PackedScene


func _on_start_button_pressed() -> void:
	start_game_requested.emit(scenario_scene, _selected_game_rules())


func _selected_game_rules() -> GameRules:
	var game_rules := GameRules.new()
	
	var pop_growth_check_box := %PopGrowthCheckBox as CheckBox
	game_rules.population_growth = pop_growth_check_box.button_pressed
	
	var fortresses_check_box := %FortressesCheckBox as CheckBox
	game_rules.fortresses = fortresses_check_box.button_pressed
	
	var turn_limit_check_box := %TurnLimitCheckBox as CheckBox
	game_rules.turn_limit_enabled = turn_limit_check_box.button_pressed
	game_rules.turn_limit = roundi((%TurnLimitSpinBox as SpinBox).value)
	
	return game_rules
