class_name GameSave
## Class responsible for saving a game using any given file format.
## (JSON is currently the only supported format)
##
## In the future, when more file formats are supported,
## you will be able to provide a specific file format.


## False if saving was successful, otherwise true.
var error: bool = true

## Gives human-friendly information on why saving failed.
var error_message: String = ""


func save_game(game: Game, file_path: String) -> void:
	var file_access := FileAccess.open(file_path, FileAccess.WRITE)
	
	if not file_access:
		# Maybe use this to make more detailed error messages
		#var error: Error = FileAccess.get_open_error()
		
		error = true
		error_message = "Failed to open the file for writing."
		return
	
	var game_to_raw := GameToRawDict.new()
	game_to_raw.convert_game(game)
	if game_to_raw.error:
		error = true
		error_message = game_to_raw.error_message
		return
	
	file_access.store_string(JSON.stringify(game_to_raw.result, "\t"))
	file_access.close()
	error = false
