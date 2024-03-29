class_name GameFromScenario
## Class responsible for loading a game using just a scenario and game rules.


var error: bool = true
var error_message: String = ""
var result: Game


func load_game(
		scenario: Scenario1,
		game_rules: GameRules,
		players: Players,
		game_scene: PackedScene
) -> void:
	var json_data: Dictionary = scenario.as_json(game_rules, players)
	var game_from_json := GameFromJSON.new()
	game_from_json.load_game(json_data, game_scene)
	
	if game_from_json.error:
		error = true
		error_message = game_from_json.error_message
		return
	
	var game: Game = game_from_json.result
	game.init2()
	
	# Success!
	error = false
	result = game
