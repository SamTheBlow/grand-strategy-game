class_name GameFromPath
## Class responsible for loading a game using only a file path.


var error: bool = true
var error_message: String = ""
var result: Game


func load_game(file_path: String, game_scene: PackedScene) -> void:
	var game_load := GameLoad.new()
	game_load.load_game(file_path, game_scene)
	
	if game_load.error:
		error = true
		error_message = "Failed to load game: " + game_load.error_message
		return
	
	# Success!
	error = false
	result = game_load.result
