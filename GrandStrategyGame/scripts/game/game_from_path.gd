class_name GameFromPath
## Class responsible for loading a game using only a file path.


var error: bool
var error_message: String
var result: Game


func load_game(file_path: String) -> void:
	const game_scene := preload("res://scenes/game.tscn") as PackedScene
	var game := game_scene.instantiate() as Game
	game.init()
	
	var game_load := GameLoad.new()
	game_load.load_game(file_path, game)
	if game_load.error:
		error = true
		error_message = "Failed to load game: " + game_load.error_message
		return
	
	var random_player: int = randi() % game_load.result.players.players.size()
	game.load_game_state(game_load.result, random_player)
	
	# Success!
	error = false
	result = game
