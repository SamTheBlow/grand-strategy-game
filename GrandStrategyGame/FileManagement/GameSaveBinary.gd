class_name GameSaveBinary
extends GameSave
# See: https://www.gdquest.com/tutorial/godot/best-practices/save-game-formats/


func save_state(_game_state: GameState) -> int:
	var file: FileAccess = FileAccess.open(_file_path, FileAccess.WRITE)
	file.close()
	return OK


func load_state() -> GameState:
	var file: FileAccess = FileAccess.open(_file_path, FileAccess.READ)
	file.close()
	return null
