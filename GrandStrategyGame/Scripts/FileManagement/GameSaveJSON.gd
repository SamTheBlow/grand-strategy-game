class_name GameSaveJSON
extends GameSave
# See: https://www.gdquest.com/tutorial/godot/best-practices/save-game-formats/


func save_state(game_state: GameState) -> int:
	var file: FileAccess = FileAccess.open(_file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(game_state.data().to_raw_data(), "\t"))
	file.close()
	return OK


func load_state() -> GameState:
	var file: FileAccess = FileAccess.open(_file_path, FileAccess.READ)
	var json = JSON.new()
	var error: int = json.parse(file.get_as_text(true))
	file.close()
	
	if error != OK:
		push_error("Failed to load save file")
		return null
	
	return GameState.new(
			GameStateData.from_raw_data(json.data) as GameStateArray
	)
