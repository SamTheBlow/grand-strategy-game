class_name GameLoad
## Class responsible for loading a game using any supported file format.
## (JSON is currently the only supported format)


## False if loading was successful, otherwise true.
var error: bool = true

## Gives human-friendly information on why loading failed.
var error_message: String = ""

## This is where the loaded game will be stored if loading succeeds.
var result: GameState = null


func load_game(file_path: String, modifier_mediator: ModifierMediator) -> void:
	# Load the file
	var file_json := FileJSON.new()
	file_json.load_json(file_path)
	if file_json.error:
		error = true
		error_message = file_json.error_message
		return
	
	# Load the game using the file data
	var game_from_json := GameFromJSON.new()
	game_from_json.load_game(file_json.result, modifier_mediator)
	if game_from_json.error:
		error = true
		error_message = game_from_json.error_message
		return
	
	error = false
	result = game_from_json.result
