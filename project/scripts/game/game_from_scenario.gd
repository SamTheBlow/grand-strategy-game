class_name GameFromScenario
## Class responsible for loading a game using the test map and game rules.


var error: bool = true
var error_message: String = ""
var result: Game


func load_game(scenario: Scenario1, game_rules: GameRules) -> void:
	var json_data: Dictionary = scenario.as_json(game_rules)
	var game_from_raw := GameFromRawDict.new()
	game_from_raw.load_game(json_data)
	
	if game_from_raw.error:
		error = true
		error_message = game_from_raw.error_message
		return
	
	# Success!
	error = false
	result = game_from_raw.result
