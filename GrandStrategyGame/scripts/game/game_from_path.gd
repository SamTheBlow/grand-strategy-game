class_name GameFromPath
## Class responsible for loading a game using only a file path.


var error: bool = true
var error_message: String = ""
var result: Game


func load_game(file_path: String) -> void:
	var game_load := GameLoad.new()
	game_load.load_game(file_path)
	
	if game_load.error:
		error = true
		error_message = "Failed to load game: " + game_load.error_message
		return
	var game: Game = game_load.result
	
	var random_player: int = randi() % game.players.players.size()
	game.init2(random_player)
	
	# Success!
	error = false
	result = game
