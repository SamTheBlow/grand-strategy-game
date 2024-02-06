class_name GameFromScenario
## Class responsible for loading a game using just a scenario and game rules.


var error: bool = true
var error_message: String = ""
var result: Game


func load_game(scenario: Scenario1, game_rules: GameRules) -> void:
	const game_scene := preload("res://scenes/game.tscn") as PackedScene
	var game := game_scene.instantiate() as Game
	game.init()
	
	var game_state: GameState = scenario.generate_game_state(game, game_rules)
	
	var your_id: int = scenario.human_player
	game.load_game_state(game_state, your_id)
	
	# Success!
	error = false
	result = game
