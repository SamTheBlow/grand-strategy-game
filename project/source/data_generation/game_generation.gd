class_name GameGeneration
## Base class for generating a game's data.
## Applies changes directly to given dictionary.


var error: bool = false
var error_message: String = ""


func apply(_raw_data: Dictionary) -> void:
	pass


## Updates the error and error_message properties according to the outcome.
func load_settings(_map_settings: Dictionary) -> void:
	error = false
	error_message = ""
