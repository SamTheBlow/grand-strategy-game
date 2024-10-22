class_name GameLoadPopulated
## Loads a [Game] from given file path.
## Unlike [GameLoad], this class also populates the save data
## using given generation settings (see [PopulatedSaveFile]).


var error: bool = true
var error_message: String = ""
var result: Game


func load_game(file_path: String, generation_settings: GameRules) -> void:
	# Load the file
	var file_json := FileJSON.new()
	file_json.load_json(file_path)
	if file_json.error:
		error = true
		error_message = file_json.error_message
		return
	
	# Modify the JSON data
	var populated_save_file := PopulatedSaveFile.new()
	populated_save_file.apply(file_json.result, generation_settings)
	if populated_save_file.error:
		error = true
		error_message = populated_save_file.error_message
		return
	
	# Load the game using the modified JSON data
	var game_from_raw := GameFromRawDict.new()
	game_from_raw.load_game(populated_save_file.result)
	if game_from_raw.error:
		error = true
		error_message = game_from_raw.error_message
		return
	
	# Success!
	error = false
	result = game_from_raw.result
