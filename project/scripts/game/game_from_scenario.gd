class_name GameFromScenario
## Class responsible for loading a game using just a scenario and game rules.


var error: bool = true
var error_message: String = ""
var result: Game


func load_game(
		scenario: Scenario1,
		game_rules: GameRules,
		game_scene: PackedScene
) -> void:
	var json_data: Dictionary = scenario.as_json(game_rules)
	var game_from_json := GameFromJSON.new()
	game_from_json.load_game(json_data, game_scene)
	
	if game_from_json.error:
		error = true
		error_message = game_from_json.error_message
		return
	
	# Success!
	error = false
	result = game_from_json.result
