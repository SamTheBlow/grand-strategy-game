class_name GameSave
## Abstract class for saving and loading the game state.


var _file_path: String


func _init(file_path: String) -> void:
	_file_path = file_path


## To be implemented by subclasses
func save_state(_game_state: GameState) -> int:
	return ERR_METHOD_NOT_FOUND


## To be implemented by subclasses
func load_state(_game_mediator: GameMediator) -> GameState:
	return null
