class_name GameGeneration
## Base class for generating a game's data.
## Applies changes directly to given [Game].

var error: bool = false
var error_message: String = ""


## Updates the error and error_message properties according to the outcome.
func apply(_game: Game) -> void:
	error = false
	error_message = ""


## Updates the error and error_message properties according to the outcome.
func load_settings(_raw_dict: Dictionary) -> void:
	error = false
	error_message = ""
