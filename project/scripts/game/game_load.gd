class_name GameLoad
## Class responsible for loading a game using any supported file format.
## (JSON is currently the only supported format)
##
## The difference between this and [GameFromPath] is that in the future,
## this class will require you to specify what file format the data uses.
## In contrast, [GameFromPath] will only take a file path as input and will
## automatically determine what the file format is.
## This class is useful in the case where you want to
## load a game and you already know what the data type is.


## False if loading was successful, otherwise true.
var error: bool = true

## Gives human-friendly information on why loading failed.
var error_message: String = ""

## This is where the loaded game will be stored if loading succeeds.
var result: Game


func load_game(file_path: String, game_scene: PackedScene) -> void:
	# Load the file
	var file_json := FileJSON.new()
	file_json.load_json(file_path)
	if file_json.error:
		error = true
		error_message = file_json.error_message
		return
	
	# Load the game using the file data
	var game_from_json := GameFromJSON.new()
	game_from_json.load_game(file_json.result, game_scene)
	if game_from_json.error:
		error = true
		error_message = game_from_json.error_message
		return
	
	error = false
	result = game_from_json.result
