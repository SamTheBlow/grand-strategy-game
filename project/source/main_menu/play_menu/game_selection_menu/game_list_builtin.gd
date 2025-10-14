class_name GameListBuiltin
extends GameListNode
## Specifically the list of built-in games.

## The list of all the built-in games, as file paths.
@export var builtin_games: Array[String] = []


func add_game(metadata: ProjectMetadata, game_id: int) -> void:
	super(metadata, game_id)

	# Hide the file path for built-in games
	if _list.size() > 0:
		_list[_list.size() - 1].is_file_path_visible = false
