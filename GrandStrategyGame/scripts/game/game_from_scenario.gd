class_name GameFromScenario
## Class responsible for loading a game using just a scenario and game rules.


var error: bool = true
var error_message: String = ""
var result: Game


func load_game(scenario: Scenario1, game_rules: GameRules) -> void:
	const game_scene := preload("res://scenes/game.tscn") as PackedScene
	var game := game_scene.instantiate() as Game
	game.init()
	
	var json_data: Dictionary = scenario.as_json(game_rules)
	var game_from_json := GameFromJSON.new()
	game_from_json.load_game(json_data, game)
	
	if game_from_json.error:
		error = true
		error_message = game_from_json.error_message
		return
	
	var your_id: int = scenario.human_player
	game.load_game_state(your_id)
	
	# Success!
	error = false
	result = game
